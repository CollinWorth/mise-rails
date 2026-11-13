require "test_helper"

class SmallThingsTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    @recipe = create_recipe(@cook, name: "Soup", ingredients: [ { name: "onion", quantity: "2" }, { name: "salt", quantity: "a pinch" } ])
    sign_in @cook
  end

  test "the recipe page scales quantities and ignores unknown scales" do
    get recipe_path(@recipe, scale: "2")
    assert_select "p", text: "4 onion"
    assert_select "p", text: "a pinch salt"
    assert_select "a[href*='/cook?scale=2']"

    get recipe_path(@recipe, scale: "banana")
    assert_select "p", text: "2 onion"
  end

  test "cook mode scales too" do
    get recipe_cook_path(@recipe, scale: "3")
    assert_select "label", text: "6 onion"
  end

  test "adding a recipe to the grocery list scales and merges" do
    @cook.grocery_list.items.create!(name: "onion", quantity: "1")

    post recipe_grocery_items_path(@recipe), params: { scale: "2" }, headers: { "HTTP_REFERER" => recipe_url(@recipe) }

    assert_redirected_to recipe_url(@recipe)
    assert_match(/Added 2 items/, flash[:notice])
    assert_equal "5", @cook.grocery_list.items.find_by(name: "onion").quantity
    assert_equal "a pinch", @cook.grocery_list.items.find_by(name: "salt").quantity
  end

  test "you can't add a private recipe from someone else to your list" do
    secret = create_recipe(create_user(name: "Other"), name: "Secret", public: false)
    post recipe_grocery_items_path(secret)
    assert_response :not_found
  end

  test "source link shows on the recipe page" do
    @recipe.update!(source_url: "https://www.example.com/soup")
    get recipe_path(@recipe)
    assert_select "a[href='https://www.example.com/soup'][rel~=noopener]", text: "Source: www.example.com"
  end

  test "share button only for public recipes" do
    get recipe_path(@recipe)
    assert_select "[data-controller=share]"

    private_recipe = create_recipe(@cook, name: "Mine", public: false)
    get recipe_path(private_recipe)
    assert_select "[data-controller=share]", count: 0
  end

  test "sign-in and sign-up fields work with the iOS password manager" do
    delete session_path
    get new_session_path
    assert_select "input[name=email_address][autocomplete=username][autocapitalize=none]"
    assert_select "input[name=password][autocomplete=current-password]"

    get new_registration_path
    assert_select "input[name='user[password]'][autocomplete=new-password]"
  end

  test "rating, commenting and following send you back to the exact page you were on" do
    scaled = recipe_url(@recipe, scale: "2")

    put recipe_rating_path(@recipe), params: { value: 2 }, headers: { "HTTP_REFERER" => scaled }
    assert_redirected_to scaled

    delete recipe_rating_path(@recipe), headers: { "HTTP_REFERER" => scaled }
    assert_redirected_to scaled

    post recipe_comments_path(@recipe), params: { comment: { body: "Nice" } }, headers: { "HTTP_REFERER" => scaled }
    assert_redirected_to scaled

    other = create_user(name: "Other")
    paged = user_url(other, page: 2)
    post user_follow_path(other), headers: { "HTTP_REFERER" => paged }
    assert_redirected_to paged
  end
end
