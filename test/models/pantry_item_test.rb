require "test_helper"

class PantryItemTest < ActiveSupport::TestCase
  setup { @user = create_user(name: "Maria") }

  test "stores a cleaned name and a matching key" do
    item = @user.pantry_items.create!(name: "  Olive   Oil ")
    assert_equal "Olive Oil", item.name
    assert_equal "olive oil", item.normalized_name
  end

  test "the same thing can't be added twice, however it's spelled" do
    @user.pantry_items.create!(name: "Onion")
    duplicate = @user.pantry_items.build(name: "onions")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:normalized_name], "is already in your pantry"
  end

  test "each user has their own pantry" do
    @user.pantry_items.create!(name: "salt")
    other = create_user(name: "Sam")

    assert other.pantry_items.build(name: "salt").valid?
    assert_equal [ "salt" ], @user.pantry_keys
    assert_empty other.pantry_keys
  end

  test "needs a name" do
    assert_not @user.pantry_items.build(name: " ").valid?
  end
end
