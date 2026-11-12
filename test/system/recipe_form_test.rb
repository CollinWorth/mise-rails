require "application_system_test_case"

class RecipeFormTest < ApplicationSystemTestCase
  test "adding and removing ingredient rows" do
    cook = create_user(name: "Maria")
    sign_in_through_form(cook)

    visit new_recipe_path
    fill_in "Name", with: "Toast"
    fill_in "recipe[ingredients_attributes][0][name]", with: "bread"
    click_button "Add ingredient"
    assert_selector "input[placeholder=Ingredient]", count: 2
    all("input[placeholder=Ingredient]").last.set("butter")
    click_button "Add ingredient"
    click_button "Remove", match: :first
    assert_selector "input[placeholder=Ingredient]", count: 2

    fill_in "Instructions (one step per line)", with: "Toast it.\nButter it."
    click_button "Save recipe"

    assert_text "Recipe saved."
    assert_text "butter"
    assert_no_text "bread"
    assert_text "2. Butter it."
  end
end
