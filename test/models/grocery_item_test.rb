require "test_helper"

class GroceryItemTest < ActiveSupport::TestCase
  test "items share the ingredient line format" do
    item = GroceryItem.new(name: "milk", quantity: "1", unit: "gallon")
    assert_equal "1 gallon milk", item.to_line
    assert_equal "2 gallon milk", item.to_line(2)
  end
end
