require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  setup do
    @author = create_user(name: "Author")
    @reader = create_user(name: "Reader")
    @recipe = create_recipe(@author, ingredients: [ { name: "flour", quantity: "2" } ])
  end

  test "copy keeps ingredients and links back to the original" do
    copy = @recipe.copy_for(@reader)
    copy.save!

    assert_equal @recipe, copy.original
    assert_not copy.public?
    assert_equal %w[flour], copy.ingredients.map(&:name)
  end

  test "editing a copy marks it modified" do
    copy = @recipe.copy_for(@reader).tap(&:save!)
    assert_not copy.modified?

    copy.update!(name: "Better soup")
    assert copy.modified?
  end

  test "ratings on a copy count toward the original" do
    copy = @recipe.copy_for(@reader).tap(&:save!)
    copy.rated_recipe.ratings.create!(user: @reader, value: 3)

    assert_equal 3.0, @recipe.average_rating
    assert_equal 3.0, copy.average_rating
  end

  test "only public recipes and your own are visible" do
    private_recipe = create_recipe(@author, name: "Secret", public: false)

    assert_includes Recipe.visible_to(@reader), @recipe
    assert_not_includes Recipe.visible_to(@reader), private_recipe
    assert_includes Recipe.visible_to(@author), private_recipe
  end

  test "accepts a photo" do
    attach_image @recipe
    assert @recipe.valid?
  end

  test "rejects an attachment that is not a photo" do
    @recipe.image.attach(io: file_fixture("notes.txt").open, filename: "notes.txt", content_type: "text/plain")

    assert_not @recipe.valid?
    assert_includes @recipe.errors[:image], "must be a JPEG, PNG, WebP or GIF"
  end

  test "an imported image URL that is not an image is rejected" do
    page = Struct.new(:body, :content_type).new("<html></html>", "text/html")
    recipe = @author.recipes.build(name: "Imported", image_url: "https://example.com/not-an-image")

    RemoteFetch.stub :get, page do
      assert_not recipe.save
    end
    assert_includes recipe.errors[:image], "must be a JPEG, PNG, WebP or GIF"
  end

  test "knows whether a user liked it and what they rated it" do
    assert_not @recipe.liked_by?(@reader)
    @recipe.likes.create!(user: @reader)
    @recipe.ratings.create!(user: @reader, value: 2)

    assert @recipe.liked_by?(@reader)
    assert_equal 2, @recipe.rating_by(@reader)
    assert_nil @recipe.rating_by(@author)
  end

  test "source link must be an http or https address" do
    %w[https://example.com/pie http://example.com].each do |url|
      assert @recipe.tap { |r| r.source_url = url }.valid?, url
    end
    [ "javascript:alert(1)", "https://x.com javascript:alert(1)", "ftp://example.com/pie", "not a url" ].each do |url|
      assert_not @recipe.tap { |r| r.source_url = url }.valid?, url
    end
    assert @recipe.tap { |r| r.source_url = "" }.valid?
  end

  test "source_host" do
    @recipe.source_url = "https://www.example.com/a/pie"
    assert_equal "www.example.com", @recipe.source_host
    @recipe.source_url = nil
    assert_nil @recipe.source_host
  end
end
