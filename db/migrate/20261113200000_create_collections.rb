# Named groups of recipes ("Weeknight", "Guests"). A collection is private unless it is made public, which shows it on the cook's
# profile and to anyone with the link.
class CreateCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :collections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :public, null: false, default: false
      t.timestamps
    end

    create_table :collection_recipes do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.timestamps
    end
    add_index :collection_recipes, [ :collection_id, :recipe_id ], unique: true
  end
end
