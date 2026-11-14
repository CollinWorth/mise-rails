# New accounts start on Lagoon, the third light theme. Existing accounts keep whatever they have.
class DefaultLightThemeLagoon < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :light_theme, from: "sunrise", to: "lagoon"
  end
end
