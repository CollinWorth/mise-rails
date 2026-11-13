# A cooking only needs the day, not the time of day: swap cooked_at for cooked_on, keeping the day each one was in (Pacific time).
class RecordCookingDayOnly < ActiveRecord::Migration[8.1]
  class Row < ActiveRecord::Base
    self.table_name = "cookings"
  end

  def up
    add_column :cookings, :cooked_on, :date
    Row.reset_column_information
    Row.find_each { |row| row.update_columns(cooked_on: row.cooked_at.in_time_zone.to_date) }
    change_column_null :cookings, :cooked_on, false
    remove_index :cookings, [ :user_id, :cooked_at ]
    remove_column :cookings, :cooked_at
    add_index :cookings, [ :user_id, :cooked_on ]
  end

  def down
    add_column :cookings, :cooked_at, :datetime
    Row.reset_column_information
    Row.find_each { |row| row.update_columns(cooked_at: row.cooked_on.in_time_zone.change(hour: 12)) }
    change_column_null :cookings, :cooked_at, false
    remove_index :cookings, [ :user_id, :cooked_on ]
    remove_column :cookings, :cooked_on
    add_index :cookings, [ :user_id, :cooked_at ]
  end
end
