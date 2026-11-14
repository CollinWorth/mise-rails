# A planned meal can be a recipe, or just some words ("Leftovers", "Pizza at Sam's"): a note has a title and no recipe.
class AllowNotesOnPlannedMeals < ActiveRecord::Migration[8.1]
  def change
    change_column_null :planned_meals, :recipe_id, true
    add_column :planned_meals, :title, :string
  end
end
