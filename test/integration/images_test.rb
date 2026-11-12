require "test_helper"

class ImagesTest < ActionDispatch::IntegrationTest
  test "recipe photos are served directly and cached, not through expiring redirects" do
    recipe = attach_image create_recipe(create_user(name: "Maria"), name: "Toast")

    get recipe_path(recipe)
    src = css_select("img").first["src"]
    assert_match %r{/rails/active_storage/representations/proxy/}, src

    get src
    assert_response :success
    assert_equal "image/jpeg", response.media_type
    assert_includes response.headers["Cache-Control"], "immutable"
    assert_includes response.headers["Cache-Control"], "public"
  end
end
