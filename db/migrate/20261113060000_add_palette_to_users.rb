class AddPaletteToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :palette, :string, null: false, default: "ember"
  end
end
