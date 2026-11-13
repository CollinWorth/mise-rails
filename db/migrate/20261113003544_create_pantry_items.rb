class CreatePantryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :pantry_items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :normalized_name, null: false

      t.timestamps
    end
    add_index :pantry_items, %i[user_id normalized_name], unique: true
  end
end
