require "application_system_test_case"

class RecipeChecklistSystemTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    @recipe = create_recipe(@cook, name: "Toast", ingredients: [ { name: "bread", quantity: "2" }, { name: "butter", quantity: "1", unit: "tbsp" } ])
    @recipe.update!(instructions: "Toast the bread.\nButter it.")
    sign_in_through_form(@cook)
    visit recipe_path(@recipe)
  end

  test "tapping an ingredient ticks it off, and tapping again undoes it" do
    find("label", text: "2 bread").click
    assert find("label", text: "2 bread").has_css?("input:checked")
    assert find("label", text: "1 tbsp butter").has_no_css?("input:checked")

    find("label", text: "2 bread").click
    assert find("label", text: "2 bread").has_no_css?("input:checked")
  end

  test "tapping a step ticks it off and its number becomes a check" do
    step = find("label", text: "Toast the bread.")
    assert step.has_no_css?("svg"), "numbered until ticked"
    other = find("label", text: "Butter it.")

    step.click
    assert step.has_css?("input:checked", visible: :all)
    assert step.has_css?("svg"), "shows a check once ticked"
    assert other.has_no_css?("input:checked", visible: :all)
  end

  test "ticks survive a reload and changing the scale, and Clear ticks removes them" do
    find("label", text: "2 bread").click
    find("label", text: "Butter it.").click

    visit current_path
    assert find("label", text: "2 bread").has_css?("input:checked")
    assert find("label", text: "Butter it.").has_css?("input:checked", visible: :all)

    click_link "2×"
    assert_text "4 bread"
    assert find("label", text: "4 bread").has_css?("input:checked")

    click_button "Clear ticks"
    assert_no_selector "input:checked", visible: :all
    visit current_path
    assert_no_selector "input:checked", visible: :all
  end

  test "ticks are kept separately for each recipe" do
    other = create_recipe(@cook, name: "Jam", ingredients: [ { name: "berries", quantity: "3" } ])
    find("label", text: "2 bread").click

    visit recipe_path(other)
    assert_no_selector "input:checked"
  end

  test "there is no cook mode" do
    assert_no_link "Cook"
    assert_raises(ActionController::RoutingError) { Rails.application.routes.recognize_path("/recipes/#{@recipe.id}/cook") }
  end

  test "the I cooked this button at the end of the steps logs it, shows when, and can be undone" do
    click_button "I cooked this"
    assert_text "Logged! That's the first time you've cooked Toast."
    assert_text "Cooked today"
    assert_text "Cooked 1 time · last today"
    assert_no_button "I cooked this"
    assert_equal 1, @cook.cookings.count

    click_button "Undo"
    assert_button "I cooked this"
    assert_no_text "Cooked today"
    assert_equal 0, @cook.cookings.count
  end
end
