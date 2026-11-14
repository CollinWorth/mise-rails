require "test_helper"

class PlannedMealTest < ActiveSupport::TestCase
  setup do
    @cook = create_user(name: "Maria")
    @soup = create_recipe(@cook, name: "Soup")
  end

  test "a note is a planned meal with words and no recipe" do
    meal = @cook.planned_meals.create!(title: "  Pizza   at Sam's ", date: Date.current)

    assert meal.note?
    assert_nil meal.recipe
    assert_equal "Pizza at Sam's", meal.title
    assert_equal "Pizza at Sam's", meal.name
  end

  test "something with neither a recipe nor words is not a plan, and a note has a sensible length" do
    assert_not @cook.planned_meals.build(date: Date.current).valid?
    assert_not @cook.planned_meals.build(title: "   ", date: Date.current).valid?
    assert_not @cook.planned_meals.build(title: "x" * 81, date: Date.current).valid?
    assert @cook.planned_meals.build(title: "x" * 80, date: Date.current).valid?
    assert_match(/can't be blank for something that isn't a recipe/, @cook.planned_meals.build(date: Date.current).tap(&:valid?).errors[:title].to_sentence)
  end

  test "a recipe meal is named after its recipe, and needs no words" do
    meal = @cook.planned_meals.create!(recipe: @soup, date: Date.current)
    assert_not meal.note?
    assert_equal "Soup", meal.name
  end

  test "with_recipe leaves the notes out" do
    @cook.planned_meals.create!(recipe: @soup, date: Date.current)
    @cook.planned_meals.create!(title: "Leftovers", date: Date.current)
    assert_equal [ "Soup" ], @cook.planned_meals.with_recipe.map(&:name)
  end

  test "deleting a recipe removes its meals but keeps the notes" do
    @cook.planned_meals.create!(recipe: @soup, date: Date.current)
    @cook.planned_meals.create!(title: "Leftovers", date: Date.current)
    @soup.destroy
    assert_equal [ "Leftovers" ], @cook.planned_meals.map(&:name)
  end
end
