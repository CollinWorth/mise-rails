require "test_helper"

class PlannedMealsTest < ActionDispatch::IntegrationTest
  FRAME = { "Turbo-Frame" => "modal" }.freeze

  setup do
    @cook = create_user(name: "Maria")
    @soup = create_recipe(@cook, name: "Soup")
    @salad = create_recipe(@cook, name: "Greek Salad")
    create_recipe(create_user(name: "Other"), name: "Not Mine")
    sign_in @cook
  end

  test "the add sheet only renders inside a Turbo Frame" do
    get new_planned_meal_path(date: "2026-11-14")
    assert_redirected_to planned_meals_path(date: "2026-11-14")
  end

  test "picking a recipe for a day lists your recipes and searches them" do
    get new_planned_meal_path(date: "2026-11-14"), headers: FRAME
    assert_response :success
    assert_select "turbo-frame#modal"
    assert_select "button[name='planned_meal[recipe_id]']", count: 2
    assert_select "input[name='planned_meal[date]'][value='2026-11-14']"
    assert_no_match(/Not Mine/, response.body)

    get new_planned_meal_path(date: "2026-11-14", q: "greek"), headers: FRAME
    assert_select "button[name='planned_meal[recipe_id]']", count: 1, text: "Greek Salad"
  end

  test "picking a day for a recipe lists the next two weeks" do
    get new_planned_meal_path(recipe_id: @soup.id), headers: FRAME
    assert_response :success
    assert_select "button[name='planned_meal[date]']", count: Views::PlannedMeals::New::DAYS_AHEAD
    assert_select "button[name='planned_meal[date]']", text: /Today/
    assert_select "input[name='planned_meal[recipe_id]'][value='#{@soup.id}']"
  end

  test "adding a meal confirms and returns to where you were" do
    post planned_meals_path, params: { planned_meal: { recipe_id: @soup.id, date: "2026-11-14", multiplier: 2 } }, headers: { "HTTP_REFERER" => recipe_url(@soup) }

    assert_redirected_to recipe_url(@soup)
    assert_match(/Added Soup to Saturday/, flash[:notice])
    assert_equal 2, @cook.planned_meals.last.multiplier
  end
end
