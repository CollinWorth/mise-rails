require "test_helper"

class PaletteTest < ActiveSupport::TestCase
  CSS = Rails.root.join("app/assets/tailwind/application.css").read
  SEEDS = %w[--p-bg --p-brand2 --p-brand3 --p-fg --p-primary --p-primary-fg --p-surface --p-tint].freeze

  # The seed colors of a theme, e.g. { "--p-bg" => "#ffffff", ... }
  def seeds(key)
    block = CSS[/^\[data-palette="#{key}"\] \{([^}]*)\}/, 1] or flunk "#{key} has no block in application.css"
    block.scan(/(--p-[a-z0-9-]+): (#[0-9a-f]{6})/).to_h
  end

  def luminance(hex)
    hex.delete("#").scan(/../).map { |pair| (pair.hex / 255.0).then { |c| c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4 } }.then { |r, g, b| 0.2126 * r + 0.7152 * g + 0.0722 * b }
  end

  def contrast(a, b)
    high, low = [ luminance(a), luminance(b) ].max, [ luminance(a), luminance(b) ].min
    (high + 0.05) / (low + 0.05)
  end

  test "there are light and dark themes, each named once" do
    assert_equal Palette::LIGHT.size + Palette::DARK.size, Palette.all.size
    assert Palette::LIGHT.size >= 3 && Palette::DARK.size >= 3
    assert_includes Palette::LIGHT, Palette::DEFAULT_LIGHT
    assert_includes Palette::DARK, Palette::DEFAULT_DARK
    assert_includes Palette::APPEARANCES, Palette::DEFAULT_APPEARANCE
  end

  test "every theme is defined in the stylesheet with all its colors" do
    Palette.all.each_key { |key| assert_equal SEEDS, seeds(key).keys.sort, key }
  end

  test "light themes are light and dark themes are dark, with cards lifted off the page" do
    Palette::LIGHT.each_key do |key|
      colors = seeds(key)
      assert_operator luminance(colors["--p-bg"]), :>, 0.5, "#{key} page"
      assert_operator luminance(colors["--p-surface"]), :>=, luminance(colors["--p-bg"]), "#{key} cards are lighter than the page"
    end
    Palette::DARK.each_key do |key|
      colors = seeds(key)
      assert_operator luminance(colors["--p-bg"]), :<, 0.1, "#{key} page"
      assert_operator luminance(colors["--p-surface"]), :>=, luminance(colors["--p-bg"]), "#{key} cards are lighter than the page"
    end
  end

  test "text and buttons stay readable in every theme" do
    Palette.all.each_key do |key|
      colors = seeds(key)
      [ "--p-bg", "--p-surface" ].each do |ground|
        assert_operator contrast(colors["--p-fg"], colors[ground]), :>=, 7, "text on #{ground} in #{key}"
        assert_operator contrast(colors["--p-brand2"], colors[ground]), :>=, 4.5, "secondary color as text on #{ground} in #{key}"
        assert_operator contrast(colors["--p-brand3"], colors[ground]), :>=, 4.5, "tertiary color as text on #{ground} in #{key}"
      end
      assert_operator contrast(colors["--p-primary-fg"], colors["--p-primary"]), :>=, 4.5, "button text in #{key}"
      assert_operator contrast(colors["--p-primary"], colors["--p-bg"]), :>=, 3, "buttons and links against the page in #{key}"
    end
  end
end
