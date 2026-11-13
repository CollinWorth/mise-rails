# One row each time someone cooks a recipe (the "I cooked this" button). It's a log, so the dates are kept, and the recipe's
# name is copied onto the row so the history survives the recipe being renamed or deleted.
class CreateCookings < ActiveRecord::Migration[8.1]
  def change
    create_table :cookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, foreign_key: true
      t.string :recipe_name, null: false
      t.datetime :cooked_at, null: false
      t.timestamps
    end
    add_index :cookings, [ :user_id, :cooked_at ]
  end
end
