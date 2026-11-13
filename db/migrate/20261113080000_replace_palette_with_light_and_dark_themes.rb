class ReplacePaletteWithLightAndDarkThemes < ActiveRecord::Migration[8.1]
  # Old single palette -> the nearest light and dark theme.
  LIGHT = { "ocean" => "lagoon", "indigo" => "lagoon", "forest" => "meadow" }.freeze
  DARK = { "ocean" => "deepsea", "indigo" => "deepsea", "plum" => "plum", "rose" => "plum" }.freeze

  def up
    add_column :users, :appearance, :string, null: false, default: "auto"
    add_column :users, :light_theme, :string, null: false, default: "sunrise"
    add_column :users, :dark_theme, :string, null: false, default: "ember"

    LIGHT.each { |old, new| execute "UPDATE users SET light_theme = #{connection.quote(new)} WHERE palette = #{connection.quote(old)}" }
    DARK.each { |old, new| execute "UPDATE users SET dark_theme = #{connection.quote(new)} WHERE palette = #{connection.quote(old)}" }

    remove_column :users, :palette
  end

  def down
    add_column :users, :palette, :string, null: false, default: "ember"
    remove_column :users, :dark_theme
    remove_column :users, :light_theme
    remove_column :users, :appearance
  end
end
