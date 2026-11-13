require "test_helper"

class ClassicLandingTest < ActionDispatch::IntegrationTest
  setup { @cook = create_user(name: "Maria") }

  test "a visitor sees the landing page with ways in" do
    get classic_path

    assert_response :success
    assert_select "h1", text: /Dinner,\s*decided\./
    assert_select "a[href='#{new_registration_path}']", minimum: 2
    assert_select "a[href='#{new_session_path}']", minimum: 1
    assert_select "a[href='#{discover_path}']", minimum: 1
    assert_select "nav.fixed", count: 0, message: "no tab bar for visitors"
  end

  test "a signed-in cook goes straight to their recipes" do
    sign_in @cook
    get classic_path
    assert_redirected_to recipes_path
  end

  test "signing in lands on the recipes, not back on the landing page" do
    post session_path, params: { email_address: @cook.email_address, password: "secret123" }
    assert_redirected_to recipes_url
  end

  test "with no public recipes yet it still looks full, using sample dishes and no community strip" do
    get classic_path

    assert_select "body", text: /Honey Garlic Tofu/
    assert_select ".marquee", count: 0
  end

  test "the collage and the strip show real public recipes with photos, and never private ones or saved copies" do
    3.times { |n| attach_image create_recipe(@cook, name: "Public dish #{n}") }
    attach_image create_recipe(@cook, name: "Secret dish", public: false)
    shared = create_recipe(create_user(name: "Sam"), name: "Original")
    create_recipe(@cook, name: "A copy of it").update!(original: shared)
    create_recipe(@cook, name: "No photo dish")

    get classic_path

    assert_select ".marquee a[href^='/recipes/']", minimum: 6
    assert_select "body", text: /Public dish 0/
    assert_select "body", text: /Secret dish/, count: 0
    assert_select "body", text: /A copy of it/, count: 0
    assert_select "body", text: /No photo dish/, count: 0
  end

  test "every theme can be tried on the page" do
    get classic_path

    assert_select "button[data-landing-palette-target=tile]", count: Palette.all.size
    Palette::LIGHT.each_key { |key| assert_select "button[data-palette=#{key}][data-mode=light]" }
    Palette::DARK.each_key { |key| assert_select "button[data-palette=#{key}][data-mode=dark]" }
  end

  test "the page follows the visitor's device by default" do
    get classic_path
    assert_select "html[data-appearance=auto]"
  end
end
