require "test_helper"

# Pages are built from components (the RubyUI library plus the small layout kit in app/components), not from raw tags, so
# that look and theme live in one place. Layout and typography belong inside a component; views only compose them.
class ViewsUseComponentsTest < ActiveSupport::TestCase
  RAW_TAG = /^\s*(?:div|span|p|h[1-6]|section|header|footer|nav|main|aside|ol|ul|li|label|button|a|img|form|table|tr|td|th|textarea|select|small|strong|em|b|i)(?:\(| \{| do\b)/

  test "views contain no raw layout, text or form tags" do
    offenders = Dir[Rails.root.join("app/views/**/*.rb")].flat_map do |path|
      relative = Pathname(path).relative_path_from(Rails.root).to_s
      File.foreach(path).with_index(1).filter_map { |line, number| "#{relative}:#{number}: #{line.strip[0, 80]}" if line.match?(RAW_TAG) }
    end

    assert_empty offenders, "Use a component (Stack, Row, Text, Heading, Button, Link, Card...) instead of raw tags:\n#{offenders.join("\n")}"
  end
end
