class CreatePlannedMeals < ActiveRecord::Migration[8.1]
  def change
    create_table :planned_meals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :multiplier, null: false, default: 1

      t.timestamps
    end
  end
end
