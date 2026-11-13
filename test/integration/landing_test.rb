require "test_helper"

class LandingTest < ActionDispatch::IntegrationTest
  setup { @cook = create_user(name: "Maria") }

  test "a visitor's first page is the fridge door, with ways in" do
    get root_path

    assert_response :success
    assert_select "h1", text: /Mise: dinner, decided/
    assert_select "[data-controller=magnets] [data-magnets-target=magnet]", minimum: 10
    assert_select "[data-magnets-target=magnet]", text: "dinner,"
    assert_select "[data-magnets-target=magnet]", text: "decided."
    assert_select "a[href='#{new_registration_path}']", text: "Get started"
    assert_select "a[href='#{new_session_path}']", text: /Sign in/
    assert_select "a[href='#{discover_path}']", text: "Browse recipes"
    assert_select "nav.fixed", count: 0, message: "no tab bar for visitors"
  end

  test "there is one way to sign up and one to sign in, not a row of them" do
    get root_path

    assert_select "a[href='#{new_registration_path}']", count: 1
    assert_select "a[href='#{new_session_path}']", count: 1
    assert_select "header a", text: "Sign up", count: 0
    assert_select "header a", text: "Sign in", count: 0
    assert_select "header a", text: "Mise", count: 1, message: "the top bar is just the brand"
    assert_select "footer", count: 0

    get new_session_path
    assert_select "header a", text: "Sign up", message: "other pages keep the full top bar"
  end

  test "the notes work without any recipes: a grocery list and a few sample dinners" do
    get root_path

    assert_select "[data-controller=tick] button[data-tick-target=item]", count: 4
    assert_select "[data-controller=dinner]" do |notes|
      names = JSON.parse(notes.first["data-dinner-names-value"])
      assert_operator names.size, :>=, 3
      assert_select "[data-dinner-target=name]", text: names.first
    end
    assert_select "a[aria-label^='Open ']", count: 0, message: "no photo without a photo recipe"
  end

  test "real public recipes fill the dinner note, ones with photos get the photo magnet, and private ones never show" do
    attach_image create_recipe(@cook, name: "Lemon Chicken")
    create_recipe(@cook, name: "Pasta")
    create_recipe(@cook, name: "Risotto")
    create_recipe(@cook, name: "Secret Stew", public: false)

    get root_path
    assert_select "a[aria-label='Open Lemon Chicken']"
    assert_select "[data-controller=dinner]" do |notes|
      names = JSON.parse(notes.first["data-dinner-names-value"])
      assert_includes names, "Lemon Chicken"
      assert_not_includes names, "Secret Stew"
    end
    assert_no_match(/Secret Stew/, response.body)
  end

  test "every theme has a color magnet" do
    get root_path
    Palette.all.each_key { |key| assert_select "button[data-palette=#{key}][data-landing-palette-target=tile]" }
  end

  test "a signed-in cook goes straight to their recipes" do
    sign_in @cook
    get root_path
    assert_redirected_to recipes_path
  end

  test "signing out comes back to the front door" do
    sign_in @cook
    delete session_path
    assert_redirected_to root_path
  end

  test "the previous landing page is still there at /classic" do
    get classic_path
    assert_response :success
    assert_select "h1", text: /Dinner,\s*decided\./
  end
end
