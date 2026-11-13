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

  test "a recipe without a name isn't saved and the form shows why" do
    sign_in @user

    assert_no_difference "Recipe.count" do
      post recipes_path, params: { recipe: { name: "", instructions: "Boil" } }
    end

    assert_response :unprocessable_content
    assert_select "[role=alert]", text: /Name can't be blank/
  end

  test "editing a recipe into an invalid one keeps the old version" do
    sign_in @user
    recipe = create_recipe(@user, name: "Soup")

    patch recipe_path(recipe), params: { recipe: { name: "" } }

    assert_response :unprocessable_content
    assert_equal "Soup", recipe.reload.name
  end

  test "a recipe page lists the public versions other cooks made of it" do
    sign_in @user
    original = create_recipe(@user, name: "Soup")
    version = create_recipe(@other, name: "Better Soup")
    version.update!(original:, modified: true)

    get recipe_path(original)

    assert_select "h3", text: "Versions by other cooks"
    assert_select "a", text: "Better Soup"
  end

  test "text the reader is sure about goes straight to the recipe form, with a way back to check how it was read" do
    sign_in @user
    post recipes_import_path, params: { text: "Tacos\nIngredients\n2 cups masa\n1 can beans\nMethod\nMix well." }

    assert_response :unprocessable_content
    assert_select "h1", text: "New recipe"
    assert_select "input[name='recipe[name]'][value=Tacos]"
    assert_select "form[action=?] input[name=check][value='1']", recipes_import_path
    assert_select "input[name='lines[1][text]'][value='2 cups masa']"
    assert_select "input[name='lines[1][role]'][value=ingredient]"
    assert_select "button", text: "Check how I read it"
  end

  test "text the reader is unsure about goes to the sorting screen first, nothing is saved" do
    sign_in @user
    assert_no_difference -> { Recipe.count } do
      post recipes_import_path, params: { text: "Toast\nbread\nbutter\nToast the bread." }
    end

    assert_response :unprocessable_content
    assert_select "h1", text: "How I read it"
    assert_match(/sure about some of this/, response.body)
    assert_select "[data-line-sorter-target=row]", count: 4
    assert_select "input[name='lines[0][role]'][value=title]"
    assert_select "button", text: "Build recipe"
  end

  test "asking to check re-opens the sorting screen with the same roles, and building uses the cook's sorting" do
    sign_in @user
    lines = { "0" => { text: "Toast", role: "title" }, "1" => { text: "2 slices bread", role: "ingredient" }, "2" => { text: "1 tbsp butter", role: "ingredient" }, "3" => { text: "Toast it.", role: "step" } }

    post recipes_import_path, params: { lines:, check: "1" }
    assert_select "h1", text: "How I read it"
    assert_no_match(/sure about some of this/, response.body)
    assert_select "input[name='lines[3][role]'][value=step]"

    lines["2"][:role] = "step" # the cook says the butter is a step
    post recipes_import_path, params: { lines: }
    assert_select "h1", text: "New recipe"
    assert_select "input[value='2 slices bread']"
    assert_select "textarea[aria-label=Step]", text: "1 tbsp butter"
    assert_select "textarea[aria-label=Step]", text: "Toast it."
  end

  test "garbage in the lines is ignored rather than breaking the import" do
    sign_in @user
    post recipes_import_path, params: { lines: "not a hash" }
    assert_redirected_to new_recipes_import_path

    post recipes_import_path, params: { lines: { "0" => "x", "1" => { text: "Soup", role: "title" }, "2" => { text: "1 onion", role: "ingredient" }, "3" => { text: "Chop.", role: "step" } } }
    assert_select "input[name='recipe[name]'][value=Soup]"
  end

  test "the import page explains iPhone scanning and desktop pasting" do
    sign_in @user
    get new_recipes_import_path
    assert_select "h4", text: "On an iPhone or iPad"
    assert_match(/Scan Text/, response.body)
    assert_select "h4", text: "On a computer"
    assert_select "button", text: "Paste from clipboard"
    assert_select "textarea[name=text]"
    assert_select "input[type=url][name=url]"
  end
end
