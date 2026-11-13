require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "a new user follows the device with the default light and dark themes" do
    user = create_user
    assert_equal [ "auto", Palette::DEFAULT_LIGHT, Palette::DEFAULT_DARK ], [ user.appearance, user.light_theme, user.dark_theme ]
  end

  test "only known appearances and themes are accepted, and each in its own mode" do
    user = create_user
    user.assign_attributes(appearance: "dark", light_theme: "meadow", dark_theme: "plum")
    assert user.valid?

    { appearance: "sepia", light_theme: "plum", dark_theme: "meadow" }.each do |attribute, value|
      user = create_user(name: "Other #{attribute}", email: "#{attribute}@example.com")
      user.public_send("#{attribute}=", value)
      assert_not user.valid?, "#{attribute} #{value}"
      assert_includes user.errors[attribute], "is not included in the list"
    end
  end
end
