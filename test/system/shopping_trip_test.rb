require "application_system_test_case"

class ShoppingTripTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    @monday = Date.current.beginning_of_week
    salad = create_recipe(@cook, name: "Salad", ingredients: [ { name: "tomato", quantity: "3" }, { name: "salt", quantity: "1", unit: "tsp" } ])
    soup = create_recipe(@cook, name: "Soup", ingredients: [ { name: "tomato", quantity: "2" }, { name: "leek", quantity: "1" }, { name: "carrot", quantity: "4" } ])
    @cook.planned_meals.create!(recipe: salad, date: @monday)
    @cook.planned_meals.create!(recipe: soup, date: @monday + 1)
    @cook.pantry_items.create!(name: "salt")
    sign_in_through_form(@cook)
  end

  def open_review
    visit planned_meals_path
    click_link "Shop for this week"
    assert_sheet_open
  end

  test "review the week, mark one thing as always had, skip another, and add the rest" do
    open_review
    assert_text "5 tomato"
    assert_selector "span", text: "in pantry", count: 1
    assert_unchecked_field "1 tsp salt"

    click_button "Always have", match: :first # tomato, the first row
    assert_selector "[data-controller~=sheet]" # the sheet stays open
    assert_selector "span", text: "in pantry", count: 2
    assert_unchecked_field "5 tomato"
    assert_checked_field "1 leek"

    uncheck "1 leek"
    click_button "Add ticked items to grocery list"

    assert_no_selector "[data-controller~=sheet]"
    assert_text "Added 1 item."
    assert_equal [ "carrot" ], @cook.grocery_list.items.reload.map(&:name)
    assert_includes @cook.pantry_keys, "tomato"
  end

  test "unticking a meal redraws the ingredients for the others" do
    open_review
    assert_text "1 leek"

    uncheck "#{(@monday + 1).strftime('%a')} · Soup"
    assert_no_text "1 leek"
    assert_text "3 tomato"
  end

  test "an item's info button shows which meal it came from and how much" do
    @cook.grocery_list.add_meals(@cook.planned_meals.to_a)
    visit grocery_list_path

    within(:xpath, "//a[normalize-space()='5 tomato']/ancestor::div[contains(@class,'justify-between')][1]") { find("a[aria-label='Where this is from']").click }
    assert_sheet_open
    assert_link "Salad"
    assert_link "Soup"
    assert_text "3 tomato"
    assert_text "2 tomato"
    assert_text "Planned for #{@monday.strftime('%A, %b %-d')}"
    click_button "Close"
    assert_no_selector "[data-controller~=sheet]"
  end

  test "managing the pantry" do
    visit grocery_list_path
    click_link "Pantry"
    assert_text "salt"

    click_button "+ olive oil"
    assert_text "olive oil"
    assert_no_button "+ olive oil"

    fill_in "pantry_item[name]", with: "flour"
    click_button "Add"
    assert_text "flour"
    assert_field "pantry_item[name]", with: "" # the page has finished refreshing, so the next click lands on the new page

    within(:xpath, "//p[normalize-space()='salt']/ancestor::div[contains(@class,'justify-between')][1]") { click_button "Remove" }
    assert_no_selector "p", text: /\Asalt\z/, wait: 5
    assert_button "+ salt" # it's a suggestion again
    assert_equal [ "flour", "olive oil" ], @cook.pantry_keys.sort
  end
end
