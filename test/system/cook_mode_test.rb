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

  test "tapping a step dims it as done, and the scale carries into cook mode" do
    cook = create_user(name: "Maria")
    recipe = create_recipe(cook, name: "Toast", ingredients: [ { name: "bread", quantity: "2" } ])
    recipe.update!(instructions: "Toast the bread.\nButter it.")
    sign_in_through_form(cook)

    visit recipe_path(recipe)
    click_link "2×"
    assert_text "4 bread"
    click_link "Cook"
    assert_text "4 bread"

    step = find("[data-controller=done]", text: "Step 1")
    step.click
    assert_selector "[data-controller=done].opacity-40", text: "Step 1"
    assert_no_selector "[data-controller=done].opacity-40", text: "Step 2"
    step.click
    assert_no_selector "[data-controller=done].opacity-40"
  end
end
