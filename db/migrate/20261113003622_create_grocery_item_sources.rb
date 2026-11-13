class CreateGroceryItemSources < ActiveRecord::Migration[8.1]
  def change
    create_table :grocery_item_sources do |t|
      t.references :grocery_item, null: false, foreign_key: true
      t.references :recipe, foreign_key: { on_delete: :nullify }
      t.string :recipe_name, null: false
      t.date :planned_on
      t.string :quantity
      t.string :unit

      t.timestamps
    end
  end
end
