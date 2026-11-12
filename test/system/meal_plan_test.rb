require "application_system_test_case"

class MealPlanTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    @salad = create_recipe(@cook, name: "Greek Salad")
    create_recipe(@cook, name: "Soup")
    sign_in_through_form(@cook)
  end

  test "a day's Add button opens a full-screen sheet; picking a recipe adds it and the sheet closes" do
    visit planned_meals_path
    first(:link, "+ Add").click
    assert_sheet_open

    fill_in "q", with: "greek"
    assert_no_button "Soup"
    click_button "Greek Salad"

    assert_no_selector "[data-controller~=sheet]"
    assert_link "Greek Salad"
    assert_text "Added Greek Salad to Monday"
    assert_equal Date.current.beginning_of_week, @cook.planned_meals.last.date
  end

  test "closing the sheet adds nothing" do
    visit planned_meals_path
    first(:link, "+ Add").click
    assert_sheet_open
    click_button "Close"

    assert_no_selector "[data-controller~=sheet]"
    assert_equal 0, @cook.planned_meals.count
  end

  test "a recipe page can add the recipe to a chosen day" do
    visit recipe_path(@salad)
    click_link "Add to plan"
    assert_sheet_open
    click_button "Tomorrow"

    assert_no_selector "[data-controller~=sheet]"
    assert_text "Added Greek Salad"
    assert_equal Date.current + 1, @cook.planned_meals.last.date
  end
end
