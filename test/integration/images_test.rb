require "test_helper"
require "rake"

class ImagesTest < ActionDispatch::IntegrationTest
  test "recipe photos are served directly and cached, not through expiring redirects" do
    recipe = attach_image create_recipe(create_user(name: "Maria"), name: "Toast")

    get recipe_path(recipe)
    src = css_select("img").first["src"]
    assert_match %r{/rails/active_storage/representations/proxy/}, src

    get src
    assert_response :success
    assert_equal "image/webp", response.media_type, "photos are served as WebP, which is much smaller"
    assert_includes response.headers["Cache-Control"], "immutable"
    assert_includes response.headers["Cache-Control"], "public"
  end

  test "the first photos on a page load eagerly and the rest wait until they scroll into view" do
    cook = create_user(name: "Maria")
    8.times { |n| attach_image create_recipe(cook, name: "Dish #{n}") }

    get discover_path
    loading = css_select("img").map { |img| img["loading"] }
    assert_equal %w[eager] * 6 + %w[lazy] * 2, loading
    assert css_select("img").all? { |img| img["width"].present? && img["height"].present? }, "sizes are set so the page doesn't jump as photos arrive"
  end

  test "the images:variants task prepares every photo's card and hero versions" do
    cook = create_user(name: "Maria")
    2.times { |n| attach_image create_recipe(cook, name: "Dish #{n}") }
    create_recipe(cook, name: "No photo")
    ActiveStorage::VariantRecord.delete_all

    Rails.application.load_tasks unless Rake::Task.task_defined?("images:variants")
    output, = capture_io { Rake::Task["images:variants"].execute }

    assert_includes output, "Prepared 2 photos."
    assert_equal 4, ActiveStorage::VariantRecord.count
  end
end
