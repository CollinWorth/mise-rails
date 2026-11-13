require "test_helper"

class CookingsTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    @soup = create_recipe(@cook, name: "Soup")
    sign_in @cook
  end

  test "the recipe page offers the button, and signed-out visitors don't see it" do
    get recipe_path(@soup)
    assert_select "form[action=?] button", recipe_cooking_path(@soup), text: "I cooked this"
    assert_select "p", text: /Cooked \d+ time/, count: 0

    delete session_path
    get recipe_path(@soup)
    assert_select "button", text: "I cooked this", count: 0
  end

  test "pressing it logs a cooking for you, and the page then shows it with an undo" do
    assert_difference -> { @cook.cookings.count }, 1 do
      post recipe_cooking_path(@soup)
    end
    assert_redirected_to recipe_path(@soup)
    assert_match(/first time you've cooked Soup/, flash[:notice])
    assert_equal [ @soup.id, "Soup" ], @cook.cookings.pick(:recipe_id, :recipe_name)

    get recipe_path(@soup)
    assert_select "button", text: "I cooked this", count: 0
    assert_select "p", text: /Cooked today at/
    assert_select "p", text: "Cooked 1 time · last today"
    assert_select "form[action=?] button", recipe_cooking_path(@soup), text: "Undo"
  end

  test "cooking it again later counts up" do
    @cook.cookings.create!(recipe: @soup, cooked_at: 3.days.ago)
    @cook.cookings.create!(recipe: @soup, cooked_at: 2.days.ago)

    get recipe_path(@soup)
    assert_select "p", text: /Cooked 2 times · last on /
    assert_select "button", text: "I cooked this"

    post recipe_cooking_path(@soup)
    assert_match(/time #3/, flash[:notice])
  end

  test "undo takes back the latest cooking only, and only a recent one" do
    older = @cook.cookings.create!(recipe: @soup, cooked_at: 2.days.ago)
    latest = @cook.cookings.create!(recipe: @soup)

    delete recipe_cooking_path(@soup)
    assert_not Cooking.exists?(latest.id)
    assert Cooking.exists?(older.id)

    assert_no_difference -> { Cooking.count } do
      delete recipe_cooking_path(@soup)
    end
  end

  test "a cooking is yours alone: someone else's log is separate, and private recipes stay private" do
    other = create_user(name: "Other")
    other.cookings.create!(recipe: @soup)
    get recipe_path(@soup)
    assert_select "p", text: /Cooked \d/, count: 0

    secret = create_recipe(other, name: "Secret", public: false)
    assert_no_difference -> { Cooking.count } do
      post recipe_cooking_path(secret)
    end
    assert_response :not_found
  end

  test "the log needs a signed-in cook" do
    delete session_path
    post recipe_cooking_path(@soup)
    assert_redirected_to new_session_path
    assert_equal 0, Cooking.count
  end
end
