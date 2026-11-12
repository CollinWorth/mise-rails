class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :instructions
      t.integer :prep_time
      t.integer :cook_time
      t.integer :servings
      t.string :cuisine
      t.string :category
      t.string :tags
      t.boolean :public, null: false, default: false
      t.references :original, foreign_key: { to_table: :recipes }
      t.boolean :modified, null: false, default: false

      t.timestamps
    end
  end
end
