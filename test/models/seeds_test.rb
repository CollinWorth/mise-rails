require "test_helper"

# db/seeds.rb is what a new developer runs first (see the README), so it should keep working and stay safe to run twice.
class SeedsTest < ActiveSupport::TestCase
  test "the sample data loads, with photos and ingredients, and loading it again adds nothing" do
    capture_io { load Rails.root.join("db/seeds.rb") }

    assert_equal 3, User.count
    assert_operator Recipe.count, :>=, 10
    assert Recipe.all.all? { |recipe| recipe.image.attached? && recipe.ingredients.any? && recipe.steps.any? }
    assert User.find_by!(email_address: "cook@example.com").authenticate("secret123")

    assert_no_difference [ "User.count", "Recipe.count", "Ingredient.count" ] do
      capture_io { load Rails.root.join("db/seeds.rb") }
    end
  end
end
