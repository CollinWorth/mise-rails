class CreateGroceryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :grocery_items do |t|
      t.references :grocery_list, null: false, foreign_key: true
      t.string :name, null: false
      t.string :quantity
      t.string :unit
      t.string :category, null: false, default: "other"
      t.boolean :checked, null: false, default: false

      t.timestamps
    end
  end
end
