require "test_helper"

class IngredientTotalsTest < ActiveSupport::TestCase
  setup do
    @cook = create_user(name: "Maria")
    @salad = create_recipe(@cook, name: "Salad", ingredients: [ { name: "Onions", quantity: "1", unit: "" }, { name: "salt", quantity: "a pinch" } ])
    @soup = create_recipe(@cook, name: "Soup", ingredients: [ { name: "onion", quantity: "2" }, { name: "Sections", section: true } ])
  end

  test "the same ingredient is totalled across recipes and scaled by the multiplier" do
    entry = IngredientTotals.new([ [ @salad, 2 ], [ @soup, 1 ] ])["onion"]

    assert_equal 4r, entry.amount
    assert_equal "4 onions", entry.to_line
    assert_equal %w[Salad Soup], entry.recipe_names
  end

  test "each recipe's share is remembered, with its own date" do
    monday = Date.current.beginning_of_week
    entry = IngredientTotals.new([ [ @salad, 2, monday ], [ @soup, 1, monday + 2 ] ])["onion"]

    assert_equal [ 2r, 2r ], entry.sources.map(&:amount)
    assert_equal [ monday, monday + 2 ], entry.sources.map(&:planned_on)
  end

  test "free-text quantities are kept as written and section headings are skipped" do
    totals = IngredientTotals.new([ [ @salad, 1 ], [ @soup, 1 ] ])

    assert_equal "a pinch salt", totals["salt"].to_line
    assert_nil totals["sections"]
  end

  test "the same recipe twice stays two sources" do
    entry = IngredientTotals.new([ [ @soup, 1 ], [ @soup, 1 ] ])["onion"]
    assert_equal 2, entry.sources.size
    assert_equal 4r, entry.amount
  end
end
