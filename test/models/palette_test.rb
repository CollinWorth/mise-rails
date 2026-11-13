require "test_helper"

class PaletteTest < ActiveSupport::TestCase
  CSS = Rails.root.join("app/assets/tailwind/application.css").read

  # The five seed colors of a palette in light or dark mode, e.g. { "--p-bg" => "#ffffff", ... }
  def seeds(key, dark:)
    selector = dark ? %(\\[data-palette="#{key}"\\]\\.dark, \\.dark \\[data-palette="#{key}"\\]) : %(\\[data-palette="#{key}"\\])
    block = CSS[/^#{selector} \{([^}]*)\}/, 1] or flunk "#{key} has no #{dark ? 'dark' : 'light'} block in application.css"
    block.scan(/(--p-[a-z-]+): (#[0-9a-f]{6})/).to_h
  end

  def luminance(hex)
    hex.delete("#").scan(/../).map { |pair| (pair.hex / 255.0).then { |c| c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4 } }.then { |r, g, b| 0.2126 * r + 0.7152 * g + 0.0722 * b }
  end

  def contrast(a, b)
    high, low = [ luminance(a), luminance(b) ].max, [ luminance(a), luminance(b) ].min
    (high + 0.05) / (low + 0.05)
  end

  test "the default is one of the palettes, and unknown keys are rejected" do
    assert Palette.valid?(Palette::DEFAULT)
    assert_not Palette.valid?("neon")
    assert_equal "Autumn Harvest", Palette.name_for("harvest")
    assert_equal "Ember", Palette.name_for("nonsense")
  end

  test "every palette has light and dark colors in the stylesheet" do
    Palette.keys.each do |key|
      [ false, true ].each do |dark|
        assert_equal %w[--p-bg --p-fg --p-primary --p-primary-fg --p-tint], seeds(key, dark:).keys.sort, "#{key} #{dark ? 'dark' : 'light'}"
      end
    end
  end

  test "text and buttons stay readable in every palette" do
    Palette.keys.each do |key|
      [ false, true ].each do |dark|
        colors = seeds(key, dark:)
        mode = "#{key} #{dark ? 'dark' : 'light'}"
        assert_operator contrast(colors["--p-fg"], colors["--p-bg"]), :>=, 7, "text on the page in #{mode}"
        assert_operator contrast(colors["--p-primary-fg"], colors["--p-primary"]), :>=, 4.5, "button text in #{mode}"
        assert_operator contrast(colors["--p-primary"], colors["--p-bg"]), :>=, 3, "buttons and links against the page in #{mode}"
      end
    end
  end
end
