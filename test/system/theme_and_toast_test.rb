require "application_system_test_case"

class ThemeAndToastTest < ApplicationSystemTestCase
  test "dark mode toggles and survives a reload" do
    visit discover_path
    assert_no_selector "html.dark"

    click_button "Toggle theme"
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

  test "choosing a palette on the profile changes the colors at once and is remembered" do
    cook = create_user(name: "Maria")
    sign_in_through_form(cook)
    visit profile_path
    assert_equal Palette::DEFAULT, page.evaluate_script("document.documentElement.dataset.palette")

    find("label", text: "Autumn Harvest").click
    assert_equal "harvest", page.evaluate_script("document.documentElement.dataset.palette")
    assert_text "Palette changed."
    assert_equal "harvest", cook.reload.palette

    visit recipes_path
    assert_equal "harvest", page.evaluate_script("document.documentElement.dataset.palette")
    assert_equal "rgb(116, 48, 20)", page.evaluate_script("getComputedStyle(document.documentElement).getPropertyValue('--primary').trim() && getComputedStyle(document.querySelector('a[href=\"#{new_recipe_path}\"]')).backgroundColor")
  end
end
