require "test_helper"

class IngredientNameTest < ActiveSupport::TestCase
  test "plurals, case and harmless prep words collapse to one key" do
    assert_equal "onion", IngredientName.normalize("Onions")
    assert_equal "tomato", IngredientName.normalize("tomatoes")
    assert_equal "garlic", IngredientName.normalize("fresh garlic")
    assert_equal "onion", IngredientName.normalize("large onions, diced")
    assert_equal "butter", IngredientName.normalize("unsalted butter")
    assert_equal "butter", IngredientName.normalize("butter (softened)")
    assert_equal "olive oil", IngredientName.normalize("extra-virgin olive oil")
  end

  test "words that change what the item is are kept" do
    assert_equal "sweet potato", IngredientName.normalize("sweet potatoes")
    assert_equal "ground beef", IngredientName.normalize("ground beef")
    assert_equal "dark chocolate", IngredientName.normalize("dark chocolate")
    assert_equal "hot sauce", IngredientName.normalize("hot sauce")
  end

  test "blank in, blank out" do
    assert_equal "", IngredientName.normalize(nil)
    assert_equal "", IngredientName.normalize("  ")
  end
end
