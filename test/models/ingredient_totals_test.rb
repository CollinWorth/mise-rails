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

  def totals_for(*lines)
    recipes = lines.each_with_index.map { |(name, quantity, unit), n| create_recipe(@cook, name: "R#{n}", ingredients: [ { name:, quantity:, unit: } ]) }
    IngredientTotals.new(recipes.map { |recipe| [ recipe, 1 ] })
  end

  test "units of the same kind merge into the biggest unit, rounded up" do
    entries = totals_for([ "flour", "2", "cup" ], [ "flour", "1", "tbsp" ]).to_a

    assert_equal [ "2 1/4 cup flour" ], entries.map(&:to_line)
    assert_equal [ "flour|volume" ], entries.map(&:key)
    assert_equal "flour", entries.first.name_key
  end

  test "weight and volume stay separate lines for the same ingredient" do
    entries = totals_for([ "sugar", "200", "g" ], [ "sugar", "1", "cup" ]).to_a

    assert_equal [ "200 g sugar", "1 cup sugar" ], entries.map(&:to_line)
    assert_equal [ "sugar|weight", "sugar|volume" ], entries.map(&:key)
    assert_equal %w[sugar sugar], entries.map(&:name_key)
  end

  test "unknown units and typos never merge with a different unit" do
    assert_equal 2, totals_for([ "garlic", "3", "cloves" ], [ "garlic", "1", "head" ]).count
    assert_equal 2, totals_for([ "flour", "2", "cpus" ], [ "flour", "1", "cup" ]).count
    assert_equal 2, totals_for([ "lemon", "2", "" ], [ "lemon", "1", "tbsp" ]).count
  end

  test "the same unknown unit merges with itself" do
    entries = totals_for([ "garlic", "3", "cloves" ], [ "garlic", "2", "Clove" ]).to_a
    assert_equal [ "5 cloves garlic" ], entries.map(&:to_line)
  end

  test "one recipe using two units of an ingredient keeps both amounts" do
    recipe = create_recipe(@cook, name: "Cake", ingredients: [ { name: "flour", quantity: "1", unit: "cup" }, { name: "flour", quantity: "2", unit: "tbsp" } ])
    entry = IngredientTotals.new([ [ recipe, 1 ] ]).first

    assert_equal [ "1", "2" ], entry.sources.map { |source| Quantity.format(source.amount) }
    assert_equal [ "cup", "tbsp" ], entry.sources.map(&:unit)
    assert_equal "1 1/4 cup flour", entry.to_line
  end
end
