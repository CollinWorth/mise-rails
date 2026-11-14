require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  setup do
    @cook = create_user(name: "Maria")
    @other = create_user(name: "Sam")
    @soup = create_recipe(@cook, name: "Soup")
    @salad = create_recipe(@cook, name: "Salad", public: false)
    @theirs = create_recipe(@other, name: "Their stew")
    @secret = create_recipe(@other, name: "Their secret", public: false)
    @collection = @cook.collections.create!(name: "Weeknight")
  end

  test "a collection needs a name, unique for the cook whatever the case, and keeps it tidy" do
    assert_not @cook.collections.build(name: " ").valid?
    assert_not @cook.collections.build(name: "x" * 61).valid?
    assert_not @cook.collections.build(name: "WEEKNIGHT").valid?
    assert @other.collections.build(name: "Weeknight").valid?, "someone else may use the same name"
    assert_equal "Date night", @cook.collections.create!(name: "  Date   night ").name
    assert_nil @cook.collections.create!(name: "Blank about", description: "  ").description
    assert_not @cook.collections.build(name: "Long about", description: "x" * 301).valid?
  end

  test "a cook can collect their own recipes, public or private, and other people's public ones" do
    [ @soup, @salad, @theirs ].each { |recipe| @collection.add(recipe) }
    assert_equal 3, @collection.recipes.count
  end

  test "someone else's private recipe can't be collected" do
    assert_raises(ActiveRecord::RecordInvalid) { @collection.add(@secret) }
    assert_equal 0, @collection.recipes.count
  end

  test "adding the same recipe twice keeps one, and it can be taken out" do
    2.times { @collection.add(@soup) }
    assert_equal 1, @collection.collection_recipes.count
    assert @collection.includes?(@soup)

    @collection.remove(@soup)
    assert_not @collection.includes?(@soup)
    assert_equal 1, Recipe.where(id: @soup.id).count, "the recipe itself stays"
  end

  test "a visitor sees only the recipes they may see, and the newest addition first" do
    @collection.add(@soup)
    @collection.add(@salad)
    @collection.add(@theirs)

    assert_equal [ "Their stew", "Salad", "Soup" ], @collection.recipes_for(@cook).map(&:name)
    assert_equal [ "Their stew", "Soup" ], @collection.recipes_for(@other).map(&:name)
    assert_equal [ "Their stew", "Soup" ], @collection.recipes_for(nil).map(&:name)
  end

  test "the cover is a photo recipe the viewer may see; a private photo never stands for a public collection" do
    attach_image @salad
    @collection.add(@salad)
    assert_equal @salad, @collection.cover_recipe(@cook)
    assert_nil @collection.cover_recipe(@other)

    attach_image @soup
    @collection.add(@soup)
    assert_equal @soup, @collection.cover_recipe(@other)
  end

  test "who can see which collections" do
    public_one = @cook.collections.create!(name: "Shared", public: true)

    assert_equal [ @collection, public_one ].sort_by(&:id), Collection.visible_to(@cook).sort_by(&:id)
    assert_equal [ public_one ], Collection.visible_to(@other).to_a
    assert_equal [ public_one ], Collection.visible_to(nil).to_a
    assert_equal [ public_one ], @cook.collections.published.to_a
  end

  test "deleting a collection keeps its recipes; deleting a recipe or a cook cleans up" do
    @collection.add(@soup)
    @collection.destroy
    assert Recipe.exists?(@soup.id)

    other_collection = @cook.collections.create!(name: "Again")
    other_collection.add(@soup)
    assert_difference -> { CollectionRecipe.count }, -1 do
      @soup.destroy
    end
    assert_difference -> { Collection.count }, -1 do
      @cook.destroy
    end
  end
end
