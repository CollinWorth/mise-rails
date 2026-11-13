require "application_system_test_case"

class NavigationSystemTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    sign_in_through_form(@cook)
  end

  test "the account menu opens, lists the account links, and signs out" do
    visit recipes_path
    assert_no_link "Pantry"

    click_button "Account menu"
    assert_text @cook.email_address
    assert_link "Your account"
    assert_link "Pantry"

    click_button "Sign out"
    assert_current_path root_path
  end

  test "the account menu closes on Escape and on a click elsewhere" do
    visit recipes_path
    click_button "Account menu"
    assert_link "Pantry"
    find("body").send_keys(:escape)
    assert_no_link "Pantry"

    click_button "Account menu"
    assert_link "Pantry"
    find("h1").click
    assert_no_link "Pantry"
  end

  test "the account menu reaches the pantry" do
    visit recipes_path
    click_button "Account menu"
    click_link "Pantry"
    assert_current_path pantry_items_path
  end

  test "the tab bar marks the current section on a phone" do
    visit planned_meals_path
    within("nav.fixed") do
      assert_selector "a[aria-current=page]", text: "Calendar"
      assert_no_selector "a[aria-current=page]", text: "Recipes"
    end

    click_link "Groceries"
    within("nav.fixed") { assert_selector "a[aria-current=page]", text: "Groceries" }
  end

  test "the top bar marks the current section on a desktop" do
    on_desktop do
      visit recipes_path
      within("header") { assert_selector "a[aria-current=page]", text: "Recipes" }

      visit pantry_items_path
      within("header") { assert_selector "a[aria-current=page]", text: "Groceries" }
    end
  end

  test "discover's tabs show which one is selected" do
    visit discover_path
    assert_selector "a[aria-current=page]", text: "Explore"

    click_link "Following"
    assert_selector "a[aria-current=page]", text: "Following"
  end
end
