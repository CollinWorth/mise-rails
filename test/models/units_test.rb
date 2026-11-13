require "test_helper"

class UnitsTest < ActiveSupport::TestCase
  test "finds units however they are spelled" do
    { "Cups" => "cup", "cup" => "cup", "tbsp." => "tbsp", "Tablespoons" => "tbsp", "teaspoon" => "tsp", "fl. oz" => "fl oz",
      "lbs" => "lb", "Pounds" => "lb", "oz" => "oz", "ml" => "ml", "liters" => "l", "grams" => "g" }.each do |text, name|
      assert_equal name, Units.find(text)&.name, text
    end
  end

  test "doesn't guess at units it doesn't know or typos" do
    [ "cpu", "tbps", "cloves", "head", "pinch", "", nil ].each { |text| assert_nil Units.find(text), text.inspect }
  end

  test "groups say what can be merged" do
    assert_equal "volume", Units.group("cup")
    assert_equal "volume", Units.group("Tablespoons")
    assert_equal "weight", Units.group("oz")
    assert_equal "", Units.group("")
    assert_equal "", Units.group(nil)
    assert_equal "other:clove", Units.group("cloves")
    assert_equal "other:clove", Units.group("Clove")
    assert_equal "other:cpu", Units.group("cpu") # a typo only merges with the same typo
  end

  test "different known units are converted to the biggest and rounded up to the nearest quarter" do
    assert_equal [ 9 / 4r, "cup" ], Units.total([ [ 2r, "cup" ], [ 1r, "tbsp" ] ])   # 2 1/16 cup
    assert_equal [ 3 / 2r, "lb" ], Units.total([ [ 1r, "lb" ], [ 8r, "oz" ] ])
    assert_equal [ 3 / 2r, "lb" ], Units.total([ [ 8r, "oz" ], [ 1r, "lb" ] ])     # order doesn't matter
    assert_equal [ 2r, "tbsp" ], Units.total([ [ 3r, "tsp" ], [ 1r, "tbsp" ] ])
    assert_equal [ 5 / 4r, "l" ], Units.total([ [ 1r, "l" ], [ 200r, "ml" ] ])      # 1.197 l
  end

  test "the same unit is added exactly, with no rounding" do
    assert_equal [ 3 / 2r, "cup" ], Units.total([ [ 1r, "cup" ], [ 1 / 2r, "cup" ] ])
    assert_equal [ 2 / 3r, "cup" ], Units.total([ [ 1 / 3r, "cup" ], [ 1 / 3r, "cup" ] ])
    assert_equal [ 5r, "cloves" ], Units.total([ [ 3r, "cloves" ], [ 2r, "cloves" ] ])
    assert_equal [ 3r, "cup" ], Units.total([ [ 1r, "cup" ], [ 2r, "cups" ] ]) # spelling isn't a different unit
  end
end
