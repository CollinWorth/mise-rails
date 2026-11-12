require "test_helper"

# Bad input should come back as a message or a validation error, never a 500.
class BadInputTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    @recipe = create_recipe(@cook, name: "Toast")
    sign_in @cook
  end

  test "an out-of-range rating is refused with a message" do
    put recipe_rating_path(@recipe), params: { value: 9 }, headers: { "HTTP_REFERER" => recipe_url(@recipe) }

    assert_redirected_to recipe_url(@recipe)
    assert_equal "Value is not included in the list", flash[:alert]
    assert_equal 0, Rating.count
  end

  test "the calendar shrugs off a garbage date" do
    get planned_meals_path(date: "garbage")
    assert_response :success
  end

  test "an invalid planned meal is refused with a message" do
    assert_no_difference "PlannedMeal.count" do
      post planned_meals_path, params: { planned_meal: { recipe_id: @recipe.id, date: "2026-11-12", multiplier: 0 } }
    end
    assert_response :see_other
    assert_match(/Multiplier/, flash[:alert])
  end

  test "uploading something that is not a photo re-renders the form" do
    assert_no_difference "Recipe.count" do
      post recipes_path, params: { recipe: { name: "Bad", image: fixture_file_upload("notes.txt", "text/plain") } }
    end
    assert_response :unprocessable_content
    assert_match(/must be a JPEG/, response.body)
  end

  test "a blank comment is refused with a message" do
    post recipe_comments_path(@recipe), params: { comment: { body: "" } }
    assert_redirected_to recipe_path(@recipe)
    assert_match(/Body/, flash[:alert])
  end
end
