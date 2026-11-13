require "test_helper"

class RecipesTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    @other = create_user(name: "Other")
  end

  test "anonymous visitors are sent to discover, then sign in" do
    get recipes_path
    assert_redirected_to discover_path

    get new_recipe_path
    assert_redirected_to new_session_path
  end

  test "creating a recipe with ingredients" do
    sign_in @user

    assert_difference({ "Recipe.count" => 1, "Ingredient.count" => 2 }) do
      post recipes_path, params: { recipe: { name: "Pasta", instructions: "Boil\nServe", ingredients_attributes: { "0" => { name: "pasta", quantity: "1", unit: "lb" }, "1" => { name: "salt" }, "2" => { name: "" } } } }
    end
    follow_redirect!
    assert_response :success
  end

  test "private recipes are hidden from other users" do
    secret = create_recipe(@other, public: false)
    sign_in @user

    get recipe_path(secret)
    assert_response :not_found
  end

  test "only the owner can edit or delete" do
    recipe = create_recipe(@other)
    sign_in @user

    patch recipe_path(recipe), params: { recipe: { name: "Hacked" } }
    assert_response :forbidden
    delete recipe_path(recipe)
    assert_response :forbidden
  end

  test "like, rate and comment" do
    recipe = create_recipe(@other)
    sign_in @user

    post recipe_like_path(recipe)
    put recipe_rating_path(recipe), params: { value: 2 }
    post recipe_comments_path(recipe), params: { comment: { body: "Nice" } }

    assert_equal 1, recipe.likes.count
    assert_equal 2.0, recipe.average_rating
    assert_equal 1, recipe.comments.count
  end

  test "saving another cook's recipe makes a private copy" do
    recipe = create_recipe(@other, ingredients: [ { name: "rice" } ])
    sign_in @user

    assert_difference -> { @user.recipes.count }, 1 do
      post recipe_copy_path(recipe)
    end
    assert_not @user.recipes.last.public?
  end

  test "importing from pasted text previews without saving" do
    sign_in @user

    assert_no_difference "Recipe.count" do
      post recipes_import_path, params: { text: "Tacos\nIngredients\n2 cups masa\nMethod\nMix" }
    end
    assert_response :unprocessable_content, "Turbo needs a redirect or an error status after a form post"
    assert_match "masa", response.body
  end

  test "importing refuses local network addresses" do
    sign_in @user

    post recipes_import_path, params: { url: "http://127.0.0.1/admin" }
    assert_redirected_to new_recipes_import_path
    assert_response :see_other
  end
end
