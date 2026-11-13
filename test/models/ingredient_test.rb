require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  def line(quantity, factor = 1, unit: "cup", name: "flour")
    Ingredient.new(quantity:, unit:, name:).to_line(factor)
  end

  test "to_line joins quantity, unit and name" do
    assert_equal "2 cup flour", line("2")
    assert_equal "flour", line(nil, unit: nil)
  end

  test "to_line scales numeric quantities, including fractions" do
    assert_equal "4 cup flour", line("2", 2)
    assert_equal "3 cup flour", line("1 1/2", 2)
    assert_equal "1/4 cup flour", line("1/2", 1 / 2r)
    assert_equal "1 1/2 cup flour", line("½", 3)
  end

  test "to_line leaves free-text quantities alone" do
    assert_equal "a pinch cup flour", line("a pinch", 2)
  end
end
