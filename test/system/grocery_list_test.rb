require "application_system_test_case"

class GroceryListTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    @bananas = @cook.grocery_list.items.create!(name: "bananas", quantity: "6")
    @cook.grocery_list.items.create!(name: "milk")
    sign_in_through_form(@cook)
    visit grocery_list_path
  end

  test "checking an item moves it to a Checked section below, and unchecking brings it back" do
    assert_no_text "Checked"

    find("form[action='#{grocery_list_item_path(@bananas)}'] button").click
    assert_text "Checked (1)"
    assert_operator page.text.index("milk"), :<, page.text.index("Checked (1)")
    assert_operator page.text.index("Checked (1)"), :<, page.text.rindex("bananas")

    find("form[action='#{grocery_list_item_path(@bananas)}'] button").click
    assert_no_text "Checked"
  end

  test "tapping an item edits it in a sheet" do
    click_link "6 bananas"
    assert_sheet_open
    fill_in "Item", with: "plantains"
    fill_in "Quantity", with: "4"
    click_button "Save"

    assert_no_selector "[data-controller~=sheet]"
    assert_link "4 plantains"
    assert_no_link "6 bananas"
  end

  test "an item can be deleted from its sheet" do
    click_link "milk"
    assert_sheet_open
    click_button "Delete item"

    assert_no_selector "[data-controller~=sheet]"
    assert_no_link "milk"
    assert_link "6 bananas"
  end

  test "clearing checked items asks first" do
    find("form[action='#{grocery_list_item_path(@bananas)}'] button").click
    assert_text "Checked (1)"

    dismiss_confirm { click_button "Clear" }
    assert_text "Checked (1)"

    accept_confirm { click_button "Clear" }
    assert_no_text "Checked"
    assert_equal [ "milk" ], @cook.grocery_list.items.reload.map(&:name)
  end
end
