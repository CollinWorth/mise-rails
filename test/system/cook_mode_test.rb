require "application_system_test_case"

class CookModeTest < ApplicationSystemTestCase
  test "cook mode shows ingredients and each step" do
    cook = create_user(name: "Maria")
    recipe = create_recipe(cook, name: "Toast", ingredients: [ { name: "bread", quantity: "2" } ])
    recipe.update!(instructions: "Toast the bread.\nButter it.")
    sign_in_through_form(cook)

    visit recipe_path(recipe)
    click_link "Cook"

    assert_text "Step 1"
    assert_text "Step 2"
    check "2 bread"
    click_link "Done"
    assert_current_path recipe_path(recipe)
  end
end
