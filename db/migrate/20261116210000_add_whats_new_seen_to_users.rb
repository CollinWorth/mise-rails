class AddWhatsNewSeenToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :whats_new_seen_id, :integer, default: 0, null: false
  end
end
