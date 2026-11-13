require "test_helper"

class ScaleTest < ActiveSupport::TestCase
  test "pick chooses a scale by its key and falls back to 1x" do
    assert_equal 2r, Scale.pick("2").factor
    assert_equal 1 / 2r, Scale.pick("0.5").factor
    assert_equal Scale.default, Scale.pick("7")
    assert_equal Scale.default, Scale.pick(nil)
  end

  test "the default scale is left out of URLs" do
    assert_nil Scale.default.to_param
    assert_equal "2", Scale.pick("2").to_param
  end

  test "every scale has a label" do
    assert_equal %w[½× 1× 2× 3×], Scale::ALL.map(&:label)
  end
end
