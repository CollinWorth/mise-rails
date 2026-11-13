require "test_helper"

# Every color in the app should come from the active theme (bg-primary, text-muted-foreground, bg-brand-2/10 ...), so that
# changing or adding a theme restyles everything. This fails if a fixed color sneaks into the code.
class ThemeColorsTest < ActiveSupport::TestCase
  FIXED_COLOR_CLASS = /\b(?:bg|text|border|from|to|via|ring|shadow|fill|stroke|outline|divide|decoration|accent|caret)-(?:white|black|slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)(?:-\d{2,3})?\b/
  COLOR_VALUE = /(?<![\w#-])#[0-9a-fA-F]{3,8}\b|\brgba?\(|\bhsla?\(|\boklch\(/

  # Places where a literal color is required or deliberate:
  ALLOWED = {
    "app/views/pwa/manifest.json.erb" => "the app manifest only accepts literal colors",
    "app/components/layouts/application.rb" => "the browser bar color (theme-color meta) is a literal",
    "app/components/ruby_ui/button/button.rb" => "white text on the red destructive button",
    "app/components/ruby_ui/link/link.rb" => "white text on the red destructive button link"
  }.freeze

  def sources
    Dir[Rails.root.join("app/**/*.{rb,js,erb}")].map { |path| Pathname(path) }.reject { |path| path.to_s.include?("/app/assets/") }
  end

  test "no view, component or script uses a fixed color instead of a theme color" do
    offenders = sources.flat_map do |path|
      relative = path.relative_path_from(Rails.root).to_s
      next [] if ALLOWED.key?(relative)

      path.each_line.with_index(1).filter_map { |line, number| "#{relative}:#{number}: #{line.strip[0, 90]}" if line.match?(FIXED_COLOR_CLASS) || line.match?(COLOR_VALUE) }
    end

    assert_empty offenders, "Use theme colors (see app/assets/tailwind/application.css) instead of:\n#{offenders.join("\n")}"
  end

  test "the exceptions are still needed" do
    ALLOWED.each_key do |relative|
      source = Rails.root.join(relative).read
      assert source.match?(FIXED_COLOR_CLASS) || source.match?(COLOR_VALUE), "#{relative} no longer has a fixed color; remove it from ALLOWED"
    end
  end
end
