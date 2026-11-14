# The color themes people can pick in their profile: some for light mode, some for dark. The colors themselves are in
# app/assets/tailwind/application.css (eight hex colors per theme: page, card, text, main color and the text on it,
# a tint, and two accents); this file only names them.
# To add one: paste a block in that file and add a line here.
class Palette
  LIGHT = { "sunrise" => "Sunrise", "meadow" => "Meadow", "lagoon" => "Lagoon", "gruvbox" => "Gruvbox Light" }.freeze
  DARK = { "ember" => "Ember", "deepsea" => "Deep Sea", "plum" => "Plum", "gruvboxdark" => "Gruvbox Dark" }.freeze
  APPEARANCES = { "auto" => "Match my device", "light" => "Light", "dark" => "Dark" }.freeze

  DEFAULT_LIGHT = "lagoon"
  DEFAULT_DARK = "ember"
  DEFAULT_APPEARANCE = "auto"

  STYLESHEET = Rails.root.join("app/assets/tailwind/application.css")

  def self.all = LIGHT.merge(DARK)
  def self.dark?(key) = DARK.key?(key)

  # The page color of a theme, read from the stylesheet so it is only ever written once. The phone's top bar and the
  # installed app's splash screen only accept a literal color, so they take it from here.
  def self.background(key)
    backgrounds[key] || backgrounds[DEFAULT_LIGHT]
  end

  def self.backgrounds
    @backgrounds ||= STYLESHEET.read.scan(/^\[data-palette="(\w+)"\] \{[^}]*--p-bg: (#\h{6})/).to_h
  end
end
