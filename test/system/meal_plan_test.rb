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
    first(:link, "+ Add", visible: true).click
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
    first(:link, "+ Add", visible: true).click
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
      first(:link, "+ Add", visible: true).click
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
    first(:link, "+ Add", visible: true).click
    assert_sheet_open

    assert_equal page.evaluate_script("window.innerWidth"), find("[data-sheet-target=panel]").native.size.width
  end

  test "the week fits on one row on a desktop, without the phone's day strip" do
    on_desktop do
      visit planned_meals_path
      top = ->(date) { find("#day-#{date.iso8601}").native.rect.y }
      monday = Date.current.beginning_of_week
      assert_equal top.(monday), top.(monday + 6), "Monday and Sunday share a row"
      assert_no_selector "nav[aria-label='Days of the week']"
    end
  end

  test "today is highlighted in the planner" do
    visit planned_meals_path
    assert_selector "#day-#{Date.current.iso8601}[data-controller~=scroll-into-view]"
    assert_selector "nav[aria-label='Days of the week'] a", count: 7
  end

  test "the day strip on a phone scrolls to a day every time, not just the first" do
    monday = Date.current.beginning_of_week
    visit planned_meals_path
    below_strip = lambda do |date|
      page.evaluate_script("document.getElementById('day-#{date.iso8601}').getBoundingClientRect().top - document.querySelector('nav[aria-label=\"Days of the week\"]').getBoundingClientRect().bottom")
    end

    [ monday, monday + 2, monday ].each do |date|
      find("nav[aria-label='Days of the week'] a[href='#day-#{date.iso8601}']").click
      assert_selector("#day-#{date.iso8601}", wait: 2) { below_strip.(date).between?(0, 40) }
      sleep 0.9
      assert_includes 0..40, below_strip.(date).round, "#{date} should sit just under the strip"
    end
  end

  test "a planned meal can be removed from its day" do
    @cook.planned_meals.create!(recipe: @salad, date: Date.current)
    visit planned_meals_path
    assert_link "Greek Salad"
    click_button "Remove Greek Salad from #{Date.current.strftime('%A')}"

    assert_no_link "Greek Salad"
    assert_equal 0, @cook.planned_meals.count
  end

  test "the week navigation moves between weeks and comes back to today" do
    visit planned_meals_path
    assert_no_link "Today"
    click_link "Next week"
    assert_text (Date.current.beginning_of_week + 7).strftime("%b %-d")
    click_link "Today"
    assert_current_path planned_meals_path(date: Date.current)
  end

  test "a recipe's ingredients go on the grocery list from its page" do
    @salad.ingredients.create!(name: "feta", quantity: "150", unit: "g")
    visit recipe_path(@salad)
    click_button "Add to grocery list"

    assert_text "Added 1 item."
    assert_equal "150", @cook.grocery_list.items.find_by(name: "feta").quantity
  end
end
