require "test_helper"

class PlannedMealsTest < ActionDispatch::IntegrationTest
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
    get new_planned_meal_path(date: "2026-11-14"), headers: modal_headers
    assert_response :success
    assert_select "turbo-frame#modal"
    assert_select "button[name='planned_meal[recipe_id]']", count: 2
    assert_select "input[name='planned_meal[date]'][value='2026-11-14']"
    assert_no_match(/Not Mine/, response.body)

    get new_planned_meal_path(date: "2026-11-14", q: "greek"), headers: modal_headers
    assert_select "button[name='planned_meal[recipe_id]']", count: 1, text: "Greek Salad"
  end

  test "picking a day for a recipe lists the next two weeks" do
    get new_planned_meal_path(recipe_id: @soup.id), headers: modal_headers
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

  test "the calendar shows the week's range, a day for each date and what is planned" do
    monday = Date.new(2026, 11, 9)
    @cook.planned_meals.create!(recipe: @soup, date: monday, multiplier: 2)
    @cook.planned_meals.create!(recipe: @salad, date: monday + 2)

    get planned_meals_path(date: monday + 3)
    assert_select "h1", text: "Nov 9 – 15"
    assert_select "[id^=day-]", count: 7
    assert_select "#day-2026-11-09 a", text: "Soup"
    assert_select "#day-2026-11-09", text: /×2/
    assert_select "#day-2026-11-11 a", text: "Greek Salad"
    assert_match(/2 meals planned · 5 days open/, response.body)
    assert_select "a[href=?]", planned_meals_path(date: monday - 7), text: ""
    assert_select "a[aria-label='Next week'][href=?]", planned_meals_path(date: monday + 7)
    assert_select "button[aria-label=?]", "Remove Soup from Monday"
  end

  test "a week that crosses a month names both months, and an empty week says so" do
    get planned_meals_path(date: "2026-11-30")
    assert_select "h1", text: "Nov 30 – Dec 6"
    assert_match(/Nothing planned yet/, response.body)
    assert_select "a", text: "Add to grocery list", count: 0
  end

  test "the add sheet offers what you type as a note, first, above the matching recipes" do
    get new_planned_meal_path(date: "2026-11-14", q: "soup"), headers: modal_headers
    assert_select "button[name='planned_meal[title]'][value=soup]", text: /Add “soup” as a note/
    assert_select "button[name='planned_meal[recipe_id]']", text: "Soup"
    assert_select "input[name='q'][maxlength='80']"

    get new_planned_meal_path(date: "2026-11-14", q: "Leftovers"), headers: modal_headers
    assert_select "button[name='planned_meal[title]']", text: /Leftovers/
    assert_match(/No recipes match/, response.body)

    get new_planned_meal_path(date: "2026-11-14"), headers: modal_headers
    assert_select "button[name='planned_meal[title]']", count: 0
    assert_match(/type something like/, response.body)
  end

  test "a note is added to the day with no recipe, and is confirmed in your words" do
    assert_difference -> { @cook.planned_meals.count }, 1 do
      post planned_meals_path, params: { planned_meal: { title: "Pizza at Sam's", date: "2026-11-14" } }
    end

    meal = @cook.planned_meals.last
    assert_nil meal.recipe
    assert_equal [ "Pizza at Sam's", Date.new(2026, 11, 14) ], [ meal.title, meal.date ]
    assert_match(/Added “Pizza at Sam&#39;s” to Saturday|Added “Pizza at Sam's” to Saturday/, flash[:notice])
  end

  test "an empty note is refused with a message, a recipe wins over words sent with it" do
    assert_no_difference -> { PlannedMeal.count } do
      post planned_meals_path, params: { planned_meal: { title: "  ", date: "2026-11-14" } }
    end
    assert_response :redirect
    assert_match(/can't be blank/, flash[:alert])

    post planned_meals_path, params: { planned_meal: { recipe_id: @soup.id, title: "ignored", date: "2026-11-14" } }
    meal = @cook.planned_meals.last
    assert_equal @soup, meal.recipe
    assert_nil meal.title
  end

  test "the calendar shows notes as tiles you can remove, counts them, and shops only for recipes" do
    monday = Date.new(2026, 11, 9)
    @cook.planned_meals.create!(title: "Eating out", date: monday)

    get planned_meals_path(date: monday)
    assert_select "#day-2026-11-09", text: /Eating out/
    assert_select "button[aria-label='Remove Eating out from Monday']"
    assert_match(/1 meal planned · 6 days open/, response.body)
    assert_select "a", text: "Add to grocery list", count: 0, message: "a note has nothing to shop for"

    @soup.ingredients.create!(name: "lentils", quantity: "2", unit: "cup")
    @cook.planned_meals.create!(recipe: @soup, date: monday + 1)
    get planned_meals_path(date: monday)
    assert_match(/2 meals planned/, response.body)
    assert_select "a", text: "Add to grocery list"

    delete planned_meal_path(@cook.planned_meals.find_by(title: "Eating out"))
    assert_equal [ "Soup" ], @cook.planned_meals.map(&:name)
  end

  test "the grocery review and the list ignore notes" do
    monday = Date.new(2026, 11, 9)
    @soup.ingredients.create!(name: "lentils", quantity: "2", unit: "cup")
    @cook.planned_meals.create!(title: "Leftovers", date: monday)
    @cook.planned_meals.create!(recipe: @soup, date: monday)

    get new_grocery_list_meal_plan_path(date: monday), headers: modal_headers
    assert_response :success
    assert_no_match(/Leftovers/, response.body)
    assert_match(/lentils/, response.body)

    post grocery_list_meal_plan_path(date: monday)
    assert_equal [ "lentils" ], @cook.grocery_list.items.map(&:name)
  end
end
