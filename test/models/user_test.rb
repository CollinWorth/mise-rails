require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "a new user gets the default palette" do
    assert_equal Palette::DEFAULT, create_user.palette
  end

  test "only known palettes are accepted" do
    user = create_user
    user.palette = "harvest"
    assert user.valid?

    user.palette = "neon"
    assert_not user.valid?
    assert_includes user.errors[:palette], "is not included in the list"
  end
end
