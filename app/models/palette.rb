# The color palettes people can pick in their profile. The colors themselves are in
# app/assets/tailwind/palettes.css (five hex colors per light and dark mode); this list only names them.
# To add one: paste a block in that file and add a line here.
class Palette
  DEFAULT = "ember"

  NAMES = {
    "ember" => "Ember",
    "harvest" => "Autumn Harvest",
    "terracotta" => "Terracotta & Teal",
    "pastel" => "Retro Pastel",
    "amber" => "Amber Night",
    "spruce" => "Spruce & Walnut",
    "classic" => "Classic"
  }.freeze

  def self.keys = NAMES.keys
  def self.valid?(key) = NAMES.key?(key.to_s)
  def self.name_for(key) = NAMES.fetch(key.to_s, NAMES.fetch(DEFAULT))
end
