require_relative "journey_test_case"

# Two cooks (on phones): one shares a recipe, the other finds it, reacts, follows, saves a copy and cooks it. Then the first
# comes back and sees the reactions, and none of the second cook's private activity.
class SharingJourneySystemTest < JourneyTestCase
  test "share, discover, react, follow, save a copy, and see it from the other side" do
    maria = create_user(name: "Maria")
    stew = create_recipe(maria, name: "Lentil Stew", ingredients: [ { name: "lentils", quantity: "300", unit: "g" }, { name: "carrots", quantity: "2" } ])
    stew.update!(instructions: "Rinse the lentils.\nSimmer with the carrots.")
    create_recipe(maria, name: "Secret Sauce", public: false)
    create_recipe(create_user(name: "Other"), name: "Plain Toast")

    # --- Sam finds it on Discover, and sees only what is public
    create_user(name: "Sam")
    sign_in("sam@example.com")
    tab "Discover"
    assert_link "Lentil Stew", exact: true
    assert_link "Plain Toast", exact: true
    assert_no_text "Secret Sauce"

    fill_in "Search recipes", with: "lentil"
    find("input[type=search]").send_keys(:enter)
    assert_link "Lentil Stew", exact: true
    assert_no_link "Plain Toast", exact: true

    # --- react: like, rate, comment
    click_link "Lentil Stew", exact: true, match: :first
    assert_selector "h1", text: "Lentil Stew"
    click_button "♡ 0"
    assert_button "♥ 1"
    all("button", text: "★")[2].click
    assert_text "★ 3.0"
    fill_in "comment[body]", with: "Made this twice already"
    click_button "Post"
    assert_text "Comments (1)"
    assert_text "Made this twice already"

    # --- follow Maria from her recipe, then find her recipes under Following
    click_link "Maria", exact: true, match: :first
    assert_selector "h1", text: "Maria"
    click_button "Follow"
    assert_button "Unfollow"
    assert_text "1 followers"

    tab "Discover"
    click_link "Following"
    assert_link "Lentil Stew", exact: true

    # --- save a copy to his own recipes, plan it and cook it
    click_link "Lentil Stew", exact: true, match: :first
    click_button "More actions"
    click_button "Save to my recipes"
    assert_text "Saved from Maria's recipe"
    assert_text "carrots"

    click_link "Add to plan"
    assert_sheet_open
    click_button "Today"
    assert_text "Added Lentil Stew"
    click_button "I cooked this"
    assert_text "Cooked today"

    tab "Recipes"
    assert_link "Lentil Stew", exact: true

    sam = User.find_by!(email_address: "sam@example.com")
    assert_equal 1, sam.recipes.count
    assert_equal stew.id, sam.recipes.first.original_id
    assert_equal 1, sam.cookings.count

    # --- Maria's side: the like, rating and comment arrived; Sam's plan and cooking did not
    sign_out
    sign_in("maria@example.com")
    click_link "Lentil Stew", exact: true, match: :first
    assert_button "♡ 1" # one like, not hers
    assert_text "Made this twice already"
    assert_text "★ 3.0"
    assert_no_text "Cooked 1 time"
    assert_no_text "Cooked today"
    assert_equal 0, maria.cookings.count
    assert_equal 0, maria.planned_meals.count

    visit user_path(maria)
    assert_text "1 followers"
  end
end
