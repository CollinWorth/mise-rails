require "application_system_test_case"

class MealPlanSystemTest < ApplicationSystemTestCase
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

  test "a recipe card in the list can be planned without opening the recipe" do
    visit recipes_path
    click_link "Add Greek Salad to plan"
    assert_sheet_open
    click_button "Tomorrow"

    assert_no_selector "[data-controller~=sheet]"
    assert_current_path recipes_path
    assert_text "Added Greek Salad"
    assert_equal [ @salad.id, Date.current + 1 ], @cook.planned_meals.pluck(:recipe_id, :date).last
  end

  test "on a desktop the sheet is a centered dialog that the backdrop closes" do
    on_desktop do
      visit planned_meals_path
      first(:link, "+ Add").click
      assert_sheet_open

      panel = find("[data-sheet-target=panel]")
      assert_operator panel.native.size.width, :<, 700, "a dialog, not full-width"
      assert_operator panel.native.rect.x, :>, 100, "centered, not against the left edge"

      page.driver.browser.action.move_to_location(5, 5).click.perform
      assert_no_selector "[data-controller~=sheet]"
    end
  end

  test "on a phone the sheet covers the whole screen" do
    visit planned_meals_path
    first(:link, "+ Add").click
    assert_sheet_open

    assert_equal page.evaluate_script("window.innerWidth"), find("[data-sheet-target=panel]").native.size.width
  end

  test "the week fits on one row on a desktop" do
    on_desktop do
      visit planned_meals_path
      heading = ->(day) { find(:xpath, "//*[normalize-space()='#{day}']").native.rect.y }
      assert_equal heading.("Monday"), heading.("Sunday"), "Monday and Sunday share a row"
    end
  end

  test "today is highlighted in the planner" do
    visit planned_meals_path
    assert_selector "[data-controller~=scroll-into-view]", text: "Today"
  end

  test "a recipe's ingredients go on the grocery list from its page" do
    @salad.ingredients.create!(name: "feta", quantity: "150", unit: "g")
    visit recipe_path(@salad)
    click_button "Add to grocery list"

    assert_text "Added 1 item."
    assert_equal "150", @cook.grocery_list.items.find_by(name: "feta").quantity
  end
end
