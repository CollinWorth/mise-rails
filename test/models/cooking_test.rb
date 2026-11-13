require "test_helper"

class CookingTest < ActiveSupport::TestCase
  setup do
    @cook = create_user(name: "Maria")
    @recipe = create_recipe(@cook, name: "Soup")
  end

  test "it remembers the recipe's name and today's date without being told" do
    cooking = @cook.cookings.create!(recipe: @recipe)

    assert_equal "Soup", cooking.recipe_name
    assert_equal Date.current, cooking.cooked_on
  end

  test "the history survives the recipe being renamed or deleted" do
    cooking = @cook.cookings.create!(recipe: @recipe)
    @recipe.update!(name: "Better soup")
    assert_equal "Soup", cooking.reload.recipe_name

    @recipe.destroy
    assert_nil cooking.reload.recipe
    assert_equal "Soup", cooking.recipe_name
    assert_equal 1, @cook.cookings.count
  end

  test "deleting an account deletes its cooking log" do
    @cook.cookings.create!(recipe: @recipe)
    assert_difference -> { Cooking.count }, -1 do
      @cook.destroy
    end
  end

  test "newest comes first, and only a recent cooking can be undone" do
    old = @cook.cookings.create!(recipe: @recipe, cooked_on: Date.current - 3)
    recent = @cook.cookings.create!(recipe: @recipe, cooked_on: Date.current)

    assert_equal [ recent, old ], @cook.cookings.newest.to_a
    assert recent.undoable?
    assert_not old.undoable?
  end
end
