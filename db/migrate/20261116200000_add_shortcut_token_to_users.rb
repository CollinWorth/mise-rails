# A key the Siri Shortcut sends to add things to the grocery list without signing in. Only its digest is kept.
class AddShortcutTokenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :shortcut_token_digest, :string
    add_index :users, :shortcut_token_digest, unique: true
  end
end
