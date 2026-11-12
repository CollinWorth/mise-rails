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
end
