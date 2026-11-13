require "application_system_test_case"

class LandingTest < ApplicationSystemTestCase
  setup do
    cook = create_user(name: "Maria")
    4.times { |n| attach_image create_recipe(cook, name: "Dish #{n}") }
  end

  def overflow = page.evaluate_script("document.documentElement.scrollWidth - window.innerWidth")

  test "the landing page fits a phone and a desktop without sideways scrolling" do
    visit root_path
    assert_selector "h1", text: /Dinner/
    assert_operator overflow, :<=, 0, "phone"

    on_desktop do
      visit root_path
      assert_selector "h1", text: /Dinner/
      assert_operator overflow, :<=, 0, "desktop"
    end
  end

  test "Get started leads to sign up, and Browse recipes to the public recipes" do
    visit root_path
    click_link "Get started"
    assert_current_path new_registration_path

    visit root_path
    click_link "Browse recipes", match: :first
    assert_current_path discover_path
  end

  test "trying a theme restyles the page, light or dark, without saving anything" do
    visit root_path
    find("button", text: "Gruvbox Dark").click
    assert_selector "html.dark"
    assert_equal "gruvboxdark", page.evaluate_script("document.documentElement.dataset.palette")
    assert_equal "true", find("button", text: "Gruvbox Dark")["aria-pressed"]

    find("button", text: "Lagoon").click
    assert_no_selector "html.dark"
    assert_equal "lagoon", page.evaluate_script("document.documentElement.dataset.palette")
    assert_equal "false", find("button", text: "Gruvbox Dark")["aria-pressed"]
  end

  test "a tried theme is not undone by the device setting changing afterwards" do
    visit root_path
    find("button", text: "Plum").click
    page.driver.browser.execute_cdp("Emulation.setEmulatedMedia", features: [ { name: "prefers-color-scheme", value: "light" } ])
    sleep 0.3
    assert_equal "plum", page.evaluate_script("document.documentElement.dataset.palette")
    assert_selector "html.dark"
  end

  test "the whole page is there to scroll through" do
    visit root_path
    [ "Paste a link. Get a recipe.", "Drop it on a day.", "Shop once.", "Fresh from the community", "Make it yours.", "Ready when you are." ].each do |heading|
      page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
      assert_text heading
    end
  end
end
