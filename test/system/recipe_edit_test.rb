require "application_system_test_case"

class RecipeEditTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    @recipe = attach_image create_recipe(@cook, name: "Toast", ingredients: [ { name: "bread" } ])
    sign_in_through_form(@cook)
  end

  test "editing shows the current photo and can remove it" do
    visit edit_recipe_path(@recipe)
    assert_selector "img[alt=Toast]"
    check "Remove photo"
    click_button "Save recipe"

    assert_text "Recipe updated."
    assert_no_selector "img[alt=Toast]"
    assert_not @recipe.reload.image.attached?
  end

  test "adding a section heading to the ingredients" do
    visit edit_recipe_path(@recipe)
    click_button "Add section"
    fill_in "Section, e.g. For the sauce", with: "For the spread"
    click_button "Add ingredient"
    all("input[placeholder=Ingredient]").last.set("butter")
    click_button "Save recipe"

    assert_text(/for the spread/i) # shown as small capitals
    assert_equal [ "bread", "For the spread", "butter" ], @recipe.reload.ingredients.map(&:name)
    assert @recipe.ingredients.find_by(name: "For the spread").section?
  end

  test "the recipe page's menu offers edit to its owner, and saving to everyone else" do
    visit recipe_path(@recipe)
    click_button "More actions"
    assert_link "Edit"
    assert_no_button "Save to my recipes"

    click_button "Account menu"
    click_button "Sign out"
    sign_in_through_form(create_user(name: "Sam"))
    visit recipe_path(@recipe)
    click_button "More actions"
    assert_button "Save to my recipes"
    assert_no_link "Edit"
  end

  test "deleting a recipe asks first" do
    visit recipe_path(@recipe)

    click_button "More actions"
    dismiss_confirm { click_button "Delete" }
    assert Recipe.exists?(@recipe.id)

    click_button "More actions"
    accept_confirm { click_button "Delete" }
    assert_text "Recipe deleted."
    assert_not Recipe.exists?(@recipe.id)
  end
end
