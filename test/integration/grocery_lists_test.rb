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

  test "you can plan a public recipe from another cook but not a private one" do
    other = create_user(name: "Other")
    public_recipe = create_recipe(other, name: "Shared")
    private_recipe = create_recipe(other, name: "Secret", public: false)

    post planned_meals_path, params: { planned_meal: { recipe_id: public_recipe.id, date: Date.current } }
    assert_response :see_other
    assert_equal 1, @user.planned_meals.count

    post planned_meals_path, params: { planned_meal: { recipe_id: private_recipe.id, date: Date.current } }
    assert_response :not_found
  end

  test "editing an item renames it, moves it to the right aisle, and deleting removes it" do
    post grocery_list_items_path, params: { item: { name: "bananas", quantity: "6" } }
    item = @user.grocery_list.items.first
    assert_equal "produce", item.category

    patch grocery_list_item_path(item), params: { item: { name: "milk", quantity: "1", unit: "gallon" } }
    item.reload
    assert_equal [ "milk", "1", "gallon" ], [ item.name, item.quantity, item.unit ]
    assert_equal GroceryItem.categorize("milk"), item.category
    assert_not_equal "produce", item.category

    delete grocery_list_item_path(item)
    assert_equal 0, @user.grocery_list.items.count
  end

  test "the edit sheet only renders inside a Turbo Frame" do
    post grocery_list_items_path, params: { item: { name: "bananas" } }
    item = @user.grocery_list.items.first

    get edit_grocery_list_item_path(item)
    assert_redirected_to grocery_list_path

    get edit_grocery_list_item_path(item), headers: modal_headers
    assert_response :success
    assert_select "turbo-frame#modal input[name='item[name]'][value=bananas]"
  end

  test "checked items are listed in their own section below the aisles" do
    post grocery_list_items_path, params: { item: { name: "bananas" } }
    post grocery_list_items_path, params: { item: { name: "milk" } }
    patch grocery_list_item_path(@user.grocery_list.items.find_by(name: "bananas")), params: { item: { checked: "1" } }

    get grocery_list_path
    assert_select "h3, [data-slot=card-title], div", text: /Checked \(1\)/
    assert_operator response.body.index("milk"), :<, response.body.index("Checked (1)")
    assert_operator response.body.index("Checked (1)"), :<, response.body.rindex("bananas")
  end
end
