require "test_helper"

class QuantityTest < ActiveSupport::TestCase
  test "parses fractions and mixed numbers" do
    assert_equal 3r / 2, Quantity.parse("1 1/2")
    assert_equal 1r / 2, Quantity.parse("½")
    assert_equal 5r / 2, Quantity.parse("2½")
  end

  test "returns nil for text" do
    assert_nil Quantity.parse("a pinch")
    assert_nil Quantity.parse("")
  end

  test "formats back to readable text" do
    assert_equal "1 1/2", Quantity.format(3r / 2)
    assert_equal "3", Quantity.format(3r)
    assert_equal "1/4", Quantity.format(1r / 4)
  end
end
