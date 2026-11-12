require "application_system_test_case"

class ThemeAndToastTest < ApplicationSystemTestCase
  test "dark mode toggles and survives a reload" do
    visit discover_path
    assert_no_selector "html.dark"

    click_button "Theme"
    assert_selector "html.dark"

    visit discover_path
    assert_selector "html.dark"
  end

  test "flash shows as a toast that goes away" do
    sign_in_through_form(create_user(name: "Maria"))
    visit new_recipe_path
    fill_in "Name", with: "Toast"
    click_button "Save recipe"

    assert_text "Recipe saved."
    assert_no_text "Recipe saved.", wait: 6
  end
end
