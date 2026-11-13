require_relative "journey_test_case"

# Someone who has never seen the app (on a phone): lands, signs up, writes a recipe, plans it, shops for it, cooks it,
# and comes back later.
class NewCookJourneySystemTest < JourneyTestCase
  test "from the front door to a cooked dinner and back again" do
    # --- the front door
    visit root_path
    assert_text(/Dinner,\s+decided\./)

    # --- sign up lands on an empty recipe list
    sign_up(name: "Nora", email: "nora@example.com")
    assert_text "No recipes yet"

    # --- write a recipe: ingredients with amounts, steps, shared publicly
    click_link "New recipe"
    fill_in "Name", with: "Tomato Pasta"
    fill_in "Prep (min)", with: "10"
    fill_in "Cook (min)", with: "20"
    fill_in "Servings", with: "4"
    find("input[placeholder=Ingredient]").send_keys("spaghetti", :enter)
    page.driver.browser.switch_to.active_element.send_keys("200", :tab, "g")
    all("input[placeholder=Ingredient]").last.set("tomatoes")
    find("textarea[aria-label=Step]").send_keys("Boil the pasta.", :enter, "Simmer the tomatoes.", :enter, "Toss together.")
    check "Share publicly"
    click_button "Save recipe"

    assert_text "Recipe saved."
    assert_selector "h1", text: "Tomato Pasta"
    assert_text "Prep 10 min"
    assert_text "Serves 4"
    assert_text "Simmer the tomatoes."
    assert_no_text "Cooked 1 time"

    # --- tick things off while cooking (kept in the browser, per recipe)
    find("label", text: "Boil the pasta.").click
    assert_checked_field "Boil the pasta."
    find("label", text: /spaghetti/).click
    assert_selector "label", text: /spaghetti/
    assert find("label", text: /spaghetti/).has_selector?("input:checked", visible: :all)

    # --- plan it for tomorrow
    click_link "Add to plan"
    assert_sheet_open
    click_button "Tomorrow"
    assert_text "Added Tomato Pasta"

    # --- the calendar shows it, under tomorrow
    tab "Calendar"
    tomorrow = Date.current + 1
    if tomorrow.beginning_of_week != Date.current.beginning_of_week
      click_link "Next week"
    end
    within("#day-#{tomorrow.iso8601}") { assert_link "Tomato Pasta" }
    assert_text "1 meal planned"

    # --- shop for the week: review, then add
    click_link "Add to grocery list"
    assert_sheet_open
    assert_text "Tomato Pasta"
    click_button "Add ticked items to grocery list"
    assert_text "Added 2 items."

    # --- the grocery list has both ingredients; tick one off
    assert_text "spaghetti"
    assert_text "tomatoes"
    click_button "spaghetti"
    assert_text "Checked (1)"

    # --- clear the whole list: the menu asks first
    click_button "More list actions"
    click_link "Clear list…"
    assert_sheet_open
    assert_text "all 2 items (1 checked, 1 still to get)"
    click_button "Keep my list"
    assert_text "tomatoes"
    click_button "More list actions"
    click_link "Clear list…"
    assert_sheet_open
    click_button "Clear 2 items"
    assert_text "Your list is empty"

    # --- cook it
    tab "Recipes"
    click_link "Tomato Pasta", exact: true, match: :first
    assert_selector "h1", text: "Tomato Pasta"
    click_button "I cooked this"
    assert_text "Cooked today"
    assert_text "Cooked 1 time · last today"

    # --- leave and come back: everything is still there
    sign_out
    visit root_path
    assert_text(/Dinner,\s+decided\./)
    sign_in("nora@example.com")
    click_link "Tomato Pasta", exact: true, match: :first
    assert_selector "h1", text: "Tomato Pasta"
    assert_text "Cooked 1 time · last today"
    assert_text "Simmer the tomatoes."

    nora = User.find_by!(email_address: "nora@example.com")
    assert_equal [ "Tomato Pasta" ], nora.recipes.map(&:name)
    assert_equal 1, nora.cookings.count
    assert_equal tomorrow, nora.planned_meals.first.date
    assert_equal 0, nora.grocery_list.items.count
  end
end
