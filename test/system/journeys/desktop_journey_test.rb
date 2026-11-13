require_relative "journey_test_case"

# The same app on a laptop: import a recipe from pasted text, fix it up, plan it from the calendar, shop for it with the
# pantry in play, edit the list in place, and make the whole site Dark.
class DesktopJourneySystemTest < JourneyTestCase
  test "import, edit, plan, shop, tidy the list and change the look" do
    create_user(name: "Dana")

    on_desktop do
      sign_in("dana@example.com")
      assert_no_selector "nav[aria-label='Days of the week']"

      # --- import a recipe from pasted text, review it, save it
      click_link "Import"
      within("form[data-controller=paste]") do
        fill_in "Recipe text", with: "Tacos\nIngredients\n2 cups masa\n1 can beans\nMethod\nMix the masa.\nServe with beans."
        click_button "Import"
      end
      assert_selector "h1", text: "New recipe"
      assert_field "Name", with: "Tacos"
      click_button "Save recipe"
      assert_text "Recipe saved."
      assert_text "Mix the masa."

      # --- edit it: rename, and add a step
      click_button "More actions"
      click_link "Edit"
      fill_in "Name", with: "Bean Tacos"
      click_button "Add step"
      all("textarea[aria-label=Step]").last.send_keys("Add lime.")
      click_button "Save recipe"
      assert_selector "h1", text: "Bean Tacos"
      assert_text "Add lime."

      # --- plan it from the calendar: the day's + Add opens a dialog, not a full screen
      tab "Calendar"
      first(:link, "+ Add").click
      assert_sheet_open
      assert_operator find("[data-sheet-target=panel]").native.size.width, :<, 700
      fill_in "q", with: "bean"
      click_button "Bean Tacos"
      assert_no_selector "[data-controller~=sheet]"
      assert_text "1 meal planned"

      # --- shop for the week; masa is a staple, so it goes to the pantry and only beans are bought
      click_link "Add to grocery list"
      assert_sheet_open
      click_button "Add to pantry", match: :first
      assert_text "In your pantry"
      click_button "Add ticked items to grocery list"
      assert_text "Added 1 item."
      assert_text "beans"
      assert_no_text "masa"

      # --- tidy the list in place (no popup on a laptop)
      click_link "Edit beans"
      assert_no_selector "[data-controller~=sheet]"
      fill_in "Item", with: "black beans"
      fill_in "Quantity", with: "2"
      click_button "Save"
      assert_button "black beans"

      click_link "Pantry"
      assert_text "masa"

      # --- make it Dark with the Plum theme; it sticks after a reload
      click_button "Account menu"
      click_link "Your account"
      find("label", text: "Dark", exact_text: true).click
      assert_selector "html.dark"
      assert_text "Appearance updated."
      assert_no_text "Appearance updated.", wait: 6 # the first message, so the next one is the Plum save
      find("label", text: "Plum").click
      assert_selector "html[data-palette=plum]"
      assert_text "Appearance updated."
      visit recipes_path
      assert_selector "html.dark[data-palette=plum]"
    end

    dana = User.find_by!(email_address: "dana@example.com")
    assert_equal [ "Bean Tacos" ], dana.recipes.map(&:name)
    assert_equal 3, dana.recipes.first.steps.size
    assert_equal [ [ "black beans", "2" ] ], dana.grocery_list.items.pluck(:name, :quantity)
    assert_includes dana.pantry_keys, "masa"
    assert_equal [ "dark", "plum" ], [ dana.appearance, dana.dark_theme ]
  end
end
