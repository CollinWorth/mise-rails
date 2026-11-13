require "test_helper"

class ShoppingTripFlowTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    @monday = Date.current.beginning_of_week
    @salad = create_recipe(@cook, name: "Salad", ingredients: [ { name: "tomato", quantity: "3" }, { name: "salt", quantity: "1", unit: "tsp" } ])
    @soup = create_recipe(@cook, name: "Soup", ingredients: [ { name: "tomato", quantity: "2" }, { name: "leek", quantity: "1" } ])
    @salad_meal = @cook.planned_meals.create!(recipe: @salad, date: @monday)
    @soup_meal = @cook.planned_meals.create!(recipe: @soup, date: @monday + 1)
    @cook.pantry_items.create!(name: "salt")
    sign_in @cook
  end

  test "the review sheet only renders inside a Turbo Frame" do
    get new_grocery_list_meal_plan_path(date: @monday)
    assert_redirected_to planned_meals_path(date: @monday)
  end

  test "the review lists meals and merged ingredients, with pantry items unticked and flagged" do
    get new_grocery_list_meal_plan_path(date: @monday), headers: modal_headers

    assert_response :success
    assert_select "input[name='meal_ids[]'][checked]", count: 2
    assert_select "input[name='ingredient_keys[]'][value=tomato][checked]"
    assert_select "input[name='ingredient_keys[]'][value=leek][checked]"
    assert_select "input[name='ingredient_keys[]'][value=salt]:not([checked])"
    assert_select "span", text: "in pantry"
    assert_select "label", text: "5 tomato"
    assert_select "button[name=pantry_key][value=tomato]", text: "Always have"
    assert_select "button[name=pantry_key][value=salt]", count: 0
  end

  test "picking fewer meals redraws the ingredients for just those" do
    get new_grocery_list_meal_plan_path(date: @monday, meal_ids: [ "", @soup_meal.id ]), headers: modal_headers.merge("Turbo-Frame" => "shop-ingredients")

    assert_select "input[name='meal_ids[]'][checked]", count: 1
    assert_select "label", text: "2 tomato"
    assert_select "input[name='ingredient_keys[]'][value=leek]"
    assert_select "input[name='ingredient_keys[]'][value=salt]", count: 0
  end

  test "adding adds only the ticked ingredients and remembers where each came from" do
    post grocery_list_meal_plan_path, params: { date: @monday, meal_ids: [ "", @salad_meal.id, @soup_meal.id ], ingredient_keys: [ "", "tomato" ] }

    assert_redirected_to grocery_list_path
    assert_equal "Added 1 item.", flash[:notice]
    items = @cook.grocery_list.items
    assert_equal [ "tomato" ], items.map(&:name)
    assert_equal [ "Salad", "Soup" ], items.first.sources.map(&:recipe_name)
    assert_equal [ "3", "2" ], items.first.sources.map(&:quantity)
  end

  test "ticking nothing adds nothing" do
    post grocery_list_meal_plan_path, params: { date: @monday, meal_ids: [ "", @salad_meal.id ], ingredient_keys: [ "" ] }
    assert_equal "Nothing to add.", flash[:notice]
    assert_equal 0, @cook.grocery_list.items.count
  end

  test "without a review, everything except pantry items is added" do
    post grocery_list_meal_plan_path, params: { date: @monday }
    assert_match(/Added 2 items \(1 already in your pantry\)/, flash[:notice])
    assert_equal %w[leek tomato], @cook.grocery_list.items.map(&:name).sort
  end

  test "Always have adds the pantry item and redraws the review with it unticked" do
    post grocery_list_meal_plan_pantry_items_path,
         params: { date: @monday, meal_ids: [ "", @salad_meal.id, @soup_meal.id ], ingredient_keys: [ "", "tomato", "leek" ], pantry_key: "tomato" },
         as: :turbo_stream

    assert_response :success
    assert_includes response.media_type, "turbo-stream"
    assert_equal %w[salt tomato], @cook.pantry_keys.sort
    assert_select "turbo-stream[action=replace][target=shop-ingredients]"
    assert_select "input[name='ingredient_keys[]'][value=leek][checked]"
    assert_select "input[name='ingredient_keys[]'][value=tomato]:not([checked])"
    assert_select "span", text: "in pantry", count: 2
  end

  test "Always have refuses a key that isn't on the trip" do
    post grocery_list_meal_plan_pantry_items_path, params: { date: @monday, pantry_key: "caviar" }, as: :turbo_stream
    assert_response :not_found
    assert_not_includes @cook.pantry_keys, "caviar"
  end

  test "an item's sheet lists where it came from and how much each meal needed" do
    @cook.grocery_list.add_meals(@cook.planned_meals.to_a)
    item = @cook.grocery_list.items.find_by(name: "tomato")

    get grocery_list_item_path(item)
    assert_redirected_to grocery_list_path

    get grocery_list_item_path(item), headers: modal_headers
    assert_response :success
    assert_select "a[href='#{recipe_path(@salad)}']", text: "Salad"
    assert_select "a[href='#{recipe_path(@soup)}']", text: "Soup"
    assert_select "p", text: "3 tomato"
    assert_select "p", text: "2 tomato"
    assert_select "p", text: /Planned for #{@monday.strftime('%A, %b %-d')}/
  end

  test "an item added by hand says so" do
    post grocery_list_items_path, params: { item: { name: "bananas" } }
    get grocery_list_item_path(@cook.grocery_list.items.first), headers: modal_headers
    assert_select "p", text: /Added by hand/
  end

  test "the grocery list only shows the info button on items that have sources" do
    post grocery_list_items_path, params: { item: { name: "bananas" } }
    @cook.grocery_list.add_meals(@cook.planned_meals.to_a)

    get grocery_list_path
    assert_select "a[aria-label='Where this is from']", count: 2 # tomato and leek, not bananas
  end
end
