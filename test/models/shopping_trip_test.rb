require "test_helper"

class ShoppingTripTest < ActiveSupport::TestCase
  setup do
    @cook = create_user(name: "Maria")
    @monday = Date.current.beginning_of_week
    @salad = create_recipe(@cook, name: "Salad", ingredients: [ { name: "tomato", quantity: "3" }, { name: "salt", quantity: "1", unit: "tsp" } ])
    @soup = create_recipe(@cook, name: "Soup", ingredients: [ { name: "tomato", quantity: "2" } ])
    @salad_meal = @cook.planned_meals.create!(recipe: @salad, date: @monday)
    @soup_meal = @cook.planned_meals.create!(recipe: @soup, date: @monday + 2, multiplier: 2)
    @cook.planned_meals.create!(recipe: @soup, date: @monday + 7) # next week
  end

  def trip(**options) = ShoppingTrip.new(user: @cook, week_start: @monday, **options)

  test "covers one week of meals" do
    assert_equal [ @salad_meal, @soup_meal ], trip.meals
    assert_equal "#{@monday.strftime('%b %-d')} – #{(@monday + 6).strftime('%b %-d')}", trip.title
  end

  test "all meals are included unless some are picked" do
    assert_equal [ @salad_meal, @soup_meal ], trip.selected_meals
    assert_equal [ @soup_meal ], trip(meal_ids: [ @soup_meal.id.to_s ]).selected_meals
    assert_empty trip(meal_ids: []).selected_meals
    assert trip(meal_ids: [ @soup_meal.id ]).selected?(@soup_meal)
  end

  test "ingredient lines are merged across the picked meals and say where they come from" do
    lines = trip.lines.index_by(&:key)

    assert_equal "7 tomato", lines["tomato"].text # 3 + 2 x 2
    assert_equal %w[Salad Soup], lines["tomato"].recipe_names
    assert_equal "1 tsp salt", lines["salt"].text
    assert_equal [ "4 tomato" ], trip(meal_ids: [ @soup_meal.id ]).lines.map(&:text)
  end

  test "lines already in the pantry are flagged" do
    @cook.pantry_items.create!(name: "Salt")

    assert_equal({ "tomato" => false, "salt" => true }, trip.lines.to_h { |line| [ line.key, line.in_pantry ] })
  end
end
