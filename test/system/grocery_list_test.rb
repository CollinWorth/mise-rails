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

  test "tapping an item's name ticks it off" do
    click_button "bananas"
    assert_text "Checked (1)"
    assert_equal [ true ], @cook.grocery_list.items.where(name: "bananas").pluck(:checked)
  end

  test "each row shows the item first and its amount after" do
    row = find("div.group", text: "bananas")
    assert_match(/bananas\s+6/, row.text)
  end

  test "on a phone the pencil edits an item in a sheet" do
    click_link "Edit bananas"
    assert_sheet_open
    fill_in "Item", with: "plantains"
    fill_in "Quantity", with: "4"
    click_button "Save"

    assert_no_selector "[data-controller~=sheet]"
    assert_button "plantains"
    assert_no_button "bananas"
    assert_equal "4", @cook.grocery_list.items.find_by(name: "plantains").quantity
  end

  test "on a desktop the pencil edits an item in place, with no window" do
    on_desktop do
      visit grocery_list_path
      click_link "Edit bananas"
      assert_no_selector "[data-controller~=sheet]"

      fill_in "Item", with: "plantains"
      fill_in "Quantity", with: "4"
      click_button "Save"

      assert_button "plantains"
      assert_no_field "Item"
      assert_equal "4", @cook.grocery_list.items.find_by(name: "plantains").quantity
    end
  end

  test "cancelling an in-place edit puts the row back unchanged" do
    on_desktop do
      visit grocery_list_path
      click_link "Edit bananas"
      fill_in "Item", with: "something else"
      click_link "Cancel"

      assert_button "bananas"
      assert_no_field "Item"
      assert_equal "bananas", @bananas.reload.name
    end
  end

  test "an item can be deleted from its sheet" do
    click_link "Edit milk"
    assert_sheet_open
    click_button "Delete item"

    assert_no_selector "[data-controller~=sheet]"
    assert_no_button "milk"
    assert_button "bananas"
  end

  test "an item can be deleted in place on a desktop" do
    on_desktop do
      visit grocery_list_path
      click_link "Edit milk"
      click_button "Delete item"

      assert_no_button "milk"
      assert_equal [ "bananas" ], @cook.grocery_list.items.reload.map(&:name)
    end
  end

  test "the list is a narrow column on a desktop" do
    on_desktop do
      visit grocery_list_path
      assert_operator find("h1").find(:xpath, "..").native.size.width, :<=, 700
    end
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
