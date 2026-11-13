require "test_helper"

class GroceryListTest < ActiveSupport::TestCase
  setup do
    @user = create_user
    @recipe = create_recipe(@user, ingredients: [ { name: "Onion", quantity: "2" }, { name: "tomato paste", quantity: "1/2", unit: "cup" } ])
  end

  test "scales ingredients by the number of times a meal is planned" do
    @user.planned_meals.create!(recipe: @recipe, date: Date.current, multiplier: 2)
    @user.planned_meals.create!(recipe: @recipe, date: Date.current + 1)

    @user.grocery_list.add_meals(@user.planned_meals)

    items = @user.grocery_list.items.index_by(&:name)
    assert_equal "6", items["onion"].quantity
    assert_equal "1 1/2", items["tomato paste"].quantity
  end

  test "merges into items already on the list" do
    @user.grocery_list.items.create!(name: "onion", quantity: "1")
    @user.planned_meals.create!(recipe: @recipe, date: Date.current)

    @user.grocery_list.add_meals(@user.planned_meals)

    assert_equal "3", @user.grocery_list.items.find_by(name: "onion").quantity
  end

  test "sorts items into aisles, preferring the longest keyword" do
    assert_equal "canned", GroceryItem.categorize("tomato paste")
    assert_equal "produce", GroceryItem.categorize("red onion")
    assert_equal "other", GroceryItem.categorize("mystery item")
  end

  test "pantry items are left off unless you pick them yourself" do
    @user.planned_meals.create!(recipe: @recipe, date: Date.current)
    @user.pantry_items.create!(name: "onion")

    result = @user.grocery_list.add_meals(@user.planned_meals.to_a)
    assert_equal [ 1, 1 ], [ result.added, result.in_pantry ] # tomato paste added, onion already in the pantry
    assert_nil @user.grocery_list.items.find_by(name: "onion")

    @user.grocery_list.add_meals(@user.planned_meals.to_a, only: %w[onion])
    assert @user.grocery_list.items.find_by(name: "onion")
  end

  test "only adds the ingredients that were picked" do
    @recipe.ingredients.create!(name: "tomato", quantity: "3")

    result = @user.grocery_list.add_recipes([ [ @recipe, 1 ] ], only: %w[tomato])

    assert_equal 1, result.added
    assert_equal [ "tomato" ], @user.grocery_list.items.reload.map(&:name)
  end

  test "merges with an item already on the list even when the spelling differs" do
    @user.grocery_list.items.create!(name: "Onions", quantity: "1")

    @user.grocery_list.add_recipes([ [ @recipe, 1 ] ])

    onions = @user.grocery_list.items.reload.select { |item| item.name.downcase.start_with?("onion") }
    assert_equal [ "3" ], onions.map(&:quantity)
  end

  test "remembers where each item came from and how much each meal needed" do
    monday = Date.current.beginning_of_week
    other = create_recipe(@user, name: "Stew", ingredients: [ { name: "onion", quantity: "1", unit: "" } ])
    @user.grocery_list.add_recipes([ [ @recipe, 2, monday ], [ other, 1, monday + 1 ] ])

    item = @user.grocery_list.items.find_by(name: "onion")
    assert_equal [ @recipe.name, "Stew" ], item.sources.map(&:recipe_name)
    assert_equal [ "4", "1" ], item.sources.map(&:quantity)
    assert_equal [ monday, monday + 1 ], item.sources.map(&:planned_on)
    assert_equal "4 onion", item.sources.first.to_line(item.name)
  end

  test "sources survive deleting the recipe and go away with the item" do
    @user.grocery_list.add_recipes([ [ @recipe, 1 ] ])
    item = @user.grocery_list.items.find_by(name: "onion")

    @recipe.destroy
    assert_equal [ @recipe.name ], item.sources.reload.map(&:recipe_name)
    assert_nil item.sources.first.recipe

    assert_difference "GroceryItemSource.count", -1 do
      item.destroy
    end
  end

  test "result summaries" do
    assert_equal "Added 2 items.", GroceryList::Result.new(added: 2, in_pantry: 0).summary
    assert_equal "Added 1 item (3 already in your pantry).", GroceryList::Result.new(added: 1, in_pantry: 3).summary
    assert_equal "Nothing to add (2 already in your pantry).", GroceryList::Result.new(added: 0, in_pantry: 2).summary
    assert_equal "Nothing to add.", GroceryList::Result.new(added: 0, in_pantry: 0).summary
  end
end
