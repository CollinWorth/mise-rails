require "test_helper"

# What a link looks like when pasted into a chat: a title, a line about it and a picture, read from the page's tags.
class LinkPreviewsTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    @soup = create_recipe(@cook, name: "Lentil Soup", ingredients: [ { name: "lentils" }, { name: "carrots" }, { name: "stock" } ])
    @soup.update!(cuisine: "Italian", prep_time: 10, cook_time: 20, servings: 4)
  end

  def tag(name, attribute: "property") = css_select("meta[#{attribute}='#{name}']").first&.[]("content")

  test "a public recipe describes itself: title, who and what's in it, and its address" do
    get recipe_path(@soup)

    assert_select "title", text: "Lentil Soup · Mise"
    assert_equal "Lentil Soup", tag("og:title")
    assert_equal "By Maria · Italian · 30 min · Serves 4 · Made with lentils, carrots and stock", tag("og:description")
    assert_equal tag("og:description"), tag("description", attribute: "name")
    assert_equal recipe_url(@soup), tag("og:url")
    assert_equal "Mise", tag("og:site_name")
    assert_equal "summary", tag("twitter:card", attribute: "name"), "no photo, so a small card"
    assert_nil tag("og:image")
    assert_empty css_select("meta[name=robots]")
  end

  test "a recipe with a photo has an absolute JPEG picture for the preview, and a big card" do
    attach_image @soup
    get recipe_path(@soup)

    image = tag("og:image")
    assert_match(%r{\Ahttp://www\.example\.com/rails/active_storage/}, image)
    assert_equal "summary_large_image", tag("twitter:card", attribute: "name")

    get image.delete_prefix("http://www.example.com")
    assert_response :success
    assert_equal "image/jpeg", response.media_type
    assert_equal [ 1200, 630 ], Vips::Image.new_from_buffer(response.body, "").size
  end

  test "a private recipe is kept out of search engines and never offers its photo" do
    attach_image @soup
    @soup.update!(public: false)
    sign_in @cook
    get recipe_path(@soup)

    assert_select "meta[name=robots][content=noindex]"
    assert_nil tag("og:image")
  end

  test "a public collection describes itself, with its cover photo; a private one is not indexed" do
    attach_image @soup
    collection = @cook.collections.create!(name: "Weeknight", description: "Quick ones", public: true)
    collection.add(@soup)
    get collection_path(collection)

    assert_select "title", text: "Weeknight · Mise"
    assert_equal "A collection by Maria · 1 recipe · Quick ones", tag("og:description")
    assert_match(/active_storage/, tag("og:image"))
    assert_empty css_select("meta[name=robots]")

    collection.update!(public: false)
    sign_in @cook
    get collection_path(collection)
    assert_select "meta[name=robots][content=noindex]"
  end

  test "a cook's page and the front door have previews too" do
    get user_path(@cook)
    assert_equal "Maria's recipes", tag("og:title")
    assert_equal "1 public recipe on Mise", tag("og:description")

    get root_path
    assert_equal "Dinner, decided", tag("og:title")
    assert_match(/pantry/, tag("og:description"))
    assert_equal "http://www.example.com/icon.png", tag("og:image")
  end

  test "ordinary pages are only titled Mise, with no preview tags" do
    sign_in @cook
    get recipes_path
    assert_select "title", text: "Mise"
    assert_empty css_select("meta[property='og:title']")
  end
end
