require "test_helper"

# Comments, follows, and the planner's remove button: small actions between cooks.
class SocialTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    @sam = create_user(name: "Sam")
    @recipe = create_recipe(@sam, name: "Stew")
    sign_in @cook
  end

  test "a comment is posted, shown, and can be deleted by its author" do
    post recipe_comments_path(@recipe), params: { comment: { body: "Lovely" } }, headers: { "HTTP_REFERER" => recipe_url(@recipe) }
    assert_redirected_to recipe_url(@recipe)

    get recipe_path(@recipe)
    assert_select "p", text: "Lovely"

    assert_difference "Comment.count", -1 do
      delete recipe_comment_path(@recipe, Comment.last)
    end
    assert_redirected_to recipe_path(@recipe)
  end

  test "an empty comment is refused with a message" do
    assert_no_difference "Comment.count" do
      post recipe_comments_path(@recipe), params: { comment: { body: " " } }
    end
    assert_equal "Body can't be blank", flash[:alert]
  end

  test "you can't delete someone else's comment" do
    comment = @recipe.comments.create!(user: @sam, body: "Mine")

    assert_no_difference "Comment.count" do
      delete recipe_comment_path(@recipe, comment)
    end
    assert_response :not_found
  end

  test "following and unfollowing a cook" do
    post user_follow_path(@sam)
    assert_redirected_to user_path(@sam)
    assert @cook.following?(@sam)

    post user_follow_path(@sam)
    assert_equal 1, @cook.follows.count, "following twice changes nothing"

    delete user_follow_path(@sam)
    assert_not @cook.following?(@sam)
  end

  test "you can't follow yourself" do
    post user_follow_path(@cook)
    assert_not @cook.following?(@cook)
  end

  test "a planned meal can be removed by its owner and not by anyone else" do
    mine = @cook.planned_meals.create!(recipe: @recipe, date: Date.current)
    theirs = @sam.planned_meals.create!(recipe: @recipe, date: Date.current)

    assert_difference "PlannedMeal.count", -1 do
      delete planned_meal_path(mine)
    end
    assert_redirected_to planned_meals_path(date: mine.date)

    assert_no_difference "PlannedMeal.count" do
      delete planned_meal_path(theirs)
    end
    assert_response :not_found
  end

  test "a recipe that is private to someone else can't be planned" do
    secret = create_recipe(@sam, name: "Secret", public: false)

    assert_no_difference "PlannedMeal.count" do
      post planned_meals_path, params: { planned_meal: { recipe_id: secret.id, date: Date.current, multiplier: 1 } }
    end
    assert_response :not_found
  end

  test "the grocery list refuses an item with no name and says why" do
    assert_no_difference "GroceryItem.count" do
      post grocery_list_items_path, params: { item: { name: "", quantity: "2" } }
    end
    assert_redirected_to grocery_list_path
    assert_equal "Name can't be blank", flash[:alert]
  end

  test "the grocery review says so when nothing is planned" do
    get new_grocery_list_meal_plan_path(date: Date.current), headers: modal_headers
    assert_select "body", text: /Nothing is planned this week/
  end
end
