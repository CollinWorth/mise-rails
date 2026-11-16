# Which time zone a cook's days are in. Blank follows the device they're using (see Components::Layouts::Application).
class AddTimeZoneToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :time_zone, :string
  end
end
