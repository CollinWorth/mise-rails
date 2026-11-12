require "test_helper"

class GroceryListsTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    sign_in @user
  end

  test "adding, checking and clearing items" do
    post grocery_list_items_path, params: { item: { name: "bananas", quantity: "6" } }
    item = @user.grocery_list.items.first
    assert_equal "produce", item.category

    patch grocery_list_item_path(item), params: { item: { checked: "1" } }
    assert item.reload.checked?

    delete grocery_list_checked_items_path
    assert_equal 0, @user.grocery_list.items.count
  end

  test "planning a week then adding it to the list" do
    recipe = create_recipe(@user, ingredients: [ { name: "onion", quantity: "2" } ])
    post planned_meals_path, params: { planned_meal: { recipe_id: recipe.id, date: Date.current, multiplier: 2 } }
    post grocery_list_meal_plan_path, params: { date: Date.current }

    assert_equal "4", @user.grocery_list.items.find_by(name: "onion").quantity
  end

  test "can't plan someone else's recipe" do
    other_recipe = create_recipe(create_user(name: "Other"))
    post planned_meals_path, params: { planned_meal: { recipe_id: other_recipe.id, date: Date.current } }
    assert_response :not_found
  end
end
