require "application_system_test_case"

# Turbo is what decides how a form response is shown, so the import is tested in a browser.
class RecipeImportSystemTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    sign_in_through_form(@cook)
  end

  test "importing pasted text shows the recipe in the form for review, and saving it keeps it" do
    visit new_recipes_import_path
    fill_in "…or paste the recipe text", with: "Tacos\nIngredients\n2 cups masa\nMethod\nMix well"
    click_button "Import"

    assert_selector "h1", text: "New recipe"
    assert_field "Name", with: "Tacos"
    assert_selector "input[value=masa]"
    assert_equal 0, @cook.recipes.count, "nothing is saved until the form is"

    click_button "Save recipe"
    assert_text "Recipe saved."
    assert_equal [ "Tacos" ], @cook.recipes.reload.map(&:name)
    assert_equal [ "masa" ], @cook.recipes.first.ingredients.map(&:name)
  end

  test "an address that can't be imported goes back to the form with the reason" do
    visit new_recipes_import_path
    fill_in "Web address", with: "http://127.0.0.1/admin"
    click_button "Import"

    assert_current_path new_recipes_import_path
    assert_selector "h1", text: "Import a recipe"
    assert_text(/address|allowed|found/i)
  end
end
