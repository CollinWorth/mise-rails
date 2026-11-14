require "application_system_test_case"

class CollectionsSystemTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    @soup = create_recipe(@cook, name: "Lentil Soup")
    sign_in_through_form(@cook)
  end

  def open_sheet
    visit recipe_path(@soup)
    click_button "More actions"
    click_link "Add to a collection"
    assert_sheet_open
  end

  test "from a recipe: start a collection, see where it is, take it out and put it back" do
    open_sheet
    fill_in "New collection name", with: "Weeknight"
    click_button "Create"

    assert_no_selector "[data-controller~=sheet]"
    assert_text "Added Lentil Soup to Weeknight."
    assert_link "Weeknight" # "In: Weeknight" under the title
    assert_equal [ @soup ], @cook.collections.find_by!(name: "Weeknight").recipes.to_a

    open_sheet
    assert_selector "button[aria-pressed=true]", text: /Weeknight\s+In it/
    click_button "Weeknight"
    assert_no_selector "[data-controller~=sheet]"
    assert_text "Took Lentil Soup out of Weeknight."
    assert_no_link "Weeknight"

    open_sheet
    click_button "Weeknight"
    assert_text "Added Lentil Soup to Weeknight."
    assert_link "Weeknight"
  end

  test "the sheet's long collection names wrap instead of scrolling sideways" do
    @cook.collections.create!(name: "Slow roasted things for a big Sunday dinner with friends")
    open_sheet
    assert_operator page.evaluate_script("document.documentElement.scrollWidth"), :<=, page.evaluate_script("window.innerWidth")
    assert_operator page.evaluate_script("document.querySelector('[data-sheet-target=panel] .overflow-y-auto').scrollWidth"), :<=, find("[data-sheet-target=panel]").native.size.width
  end

  test "making a collection on its own, adding recipes from the cards, and removing one from it" do
    visit recipes_path
    click_link "Collections"
    assert_text "No collections yet"
    click_link "Make your first collection"
    fill_in "Name", with: "Soups"
    fill_in "About (optional)", with: "Cozy ones"
    click_button "Create collection"
    assert_selector "h1", text: "Soups"
    assert_text "Cozy ones"
    assert_text "This collection is empty"

    open_sheet
    click_button "Soups"
    assert_text "Added Lentil Soup to Soups."

    visit collections_path
    click_link "Soups"
    assert_link "Lentil Soup"
    click_button "Remove from collection"
    assert_text "Took Lentil Soup out of Soups."
    assert_text "This collection is empty"
    assert_equal 1, Recipe.where(id: @soup.id).count
  end

  test "making a collection public shows the share button, which copies the link on a computer" do
    collection = @cook.collections.create!(name: "Guests")
    visit collection_path(collection)
    assert_text "Only you can see this collection"
    assert_no_button "Share"

    click_link "Edit"
    check "Public"
    click_button "Save collection"
    assert_text "Collection saved."
    assert_button "Share"

    on_desktop do
      visit collection_path(collection)
      page.driver.browser.execute_cdp("Browser.grantPermissions", permissions: %w[clipboardReadWrite clipboardSanitizedWrite], origin: page.server_url)
      page.execute_script("Object.defineProperty(navigator, 'share', { value: undefined })") # a computer has no share sheet
      click_button "Share"
      assert_text "Link copied"
    end
  end

  test "deleting a collection asks first and keeps the recipes" do
    collection = @cook.collections.create!(name: "Temp")
    visit collection_path(collection)
    dismiss_confirm("Delete the collection Temp? The recipes in it stay.") { click_button "Delete" }
    assert Collection.exists?(collection.id)

    accept_confirm { click_button "Delete" }
    assert_text "Deleted Temp."
    assert_no_link "Temp"
    assert Recipe.exists?(@soup.id)
  end
end
