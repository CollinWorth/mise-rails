require "application_system_test_case"

# The "How I read it" screen is all Stimulus, so it is tested in a browser, tapping the way a cook would.
class RecipeSortingSystemTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Maria")
    sign_in_through_form(@cook)
  end

  def import(text)
    visit new_recipes_import_path
    within("form[data-controller=paste]") do
      fill_in "Recipe text", with: text
      click_button "Import"
    end
  end

  # The sorting screen, whether the reader asked for it or the cook opens it from the recipe form to check.
  def open_sorter(text)
    import(text)
    click_button "Check how I read it" if page.has_button?("Check how I read it", wait: 2)
    assert_selector "h1", text: "How I read it"
  end

  # A line's row, found by its exact text (the label chips are in the row's text too).
  def row_css(text) = "[data-line-sorter-target=row]:has(input[data-text-input][value=#{text.to_json}])"
  def row(text) = find(row_css(text))

  # Opens a line's tray and taps one of its buttons.
  def tap_line(text, button)
    row(text).find("button[aria-expanded]").click
    within(row(text)) { click_button button }
  end

  def count(role) = find("[data-line-sorter-target=count][data-role=#{role}]").text

  test "the reader's confident guess goes straight to the recipe, and one tap re-opens it to check" do
    import("Tacos\nIngredients\n2 cups masa\n1 can beans\nMethod\nMix the masa.")
    assert_selector "h1", text: "New recipe"
    assert_field "Name", with: "Tacos"
    assert_text "Built from your text"

    click_button "Check how I read it"
    assert_selector "h1", text: "How I read it"
    assert_equal "ingredient", row("2 cups masa")["data-role"]
    assert_equal "step", row("Mix the masa.")["data-role"]

    click_button "Build recipe"
    assert_selector "h1", text: "New recipe"
    assert_field "Name", with: "Tacos"
  end

  test "text it is unsure about asks first, and tapping a line gives it a new role" do
    import("Toast\nbread\nbutter\nToast the bread until it is golden and crisp.\nSpread the butter on while it is hot.")
    assert_selector "h1", text: "How I read it"
    assert_text "I wasn't sure about some of this"
    assert_selector "[data-line-sorter-target=row]", count: 5
    assert_equal "4", count("step")

    tap_line("bread", "Ingredient")
    tap_line("butter", "Ingredient")

    assert_equal "ingredient", row("bread")["data-role"]
    assert_equal "ingredient", row("butter")["data-role"]
    assert_selector row_css("bread") + " span.rounded-full", text: "Ingredient", visible: :visible # the label is actually on screen
    assert_selector row_css("Toast"), text: "Title"
    assert_equal "2", count("ingredient")
    assert_equal "2", count("step")

    click_button "Build recipe"
    assert_selector "h1", text: "New recipe"
    assert_field "Name", with: "Toast"
    assert_selector "input[placeholder=Ingredient]", count: 2
    assert_selector "textarea[aria-label=Step]", count: 2
  end

  test "one tap moves the whole boundary between ingredients and steps" do
    # Every line starts with an amount, so the reader takes them all for ingredients.
    open_sorter("Soup\n2 onions\n1 carrot\n2 tablespoons of butter should be melted first in a deep pan\n1 minute later add the onions and stir")

    tap_line("2 tablespoons of butter should be melted first in a deep pan", "From here down are steps")

    assert_equal "ingredient", row("2 onions")["data-role"]
    assert_equal "step", row("2 tablespoons of butter should be melted first in a deep pan")["data-role"]
    assert_equal "step", row("1 minute later add the onions and stir")["data-role"]
    assert_equal "2", count("step")
    assert_equal "2", count("ingredient")
  end

  test "the other way: one tap makes everything above a line ingredients" do
    # The reader takes the long plain lines for steps, because they have no amount.
    open_sorter("Soup\n2 onions\nFresh chopped flat leaf parsley for garnish\nGood quality extra virgin olive oil for drizzling\nChop the onions.")
    assert_equal "step", row("Fresh chopped flat leaf parsley for garnish")["data-role"]

    tap_line("Good quality extra virgin olive oil for drizzling", "From here up are ingredients")

    assert_equal "ingredient", row("Fresh chopped flat leaf parsley for garnish")["data-role"]
    assert_equal "ingredient", row("Good quality extra virgin olive oil for drizzling")["data-role"]
    assert_equal "step", row("Chop the onions.")["data-role"]
  end

  test "a stray line can be skipped, and making another line the title demotes the old one" do
    open_sorter("Cake\n2 cups flour\n1 cup sugar\nPage 4 of 10\nMix everything together in a big bowl and bake for forty minutes.")

    tap_line("Page 4 of 10", "Skip")
    assert_equal "skip", row("Page 4 of 10")["data-role"]

    tap_line("2 cups flour", "Title")
    assert_equal "title", row("2 cups flour")["data-role"]
    assert_equal "skip", row("Cake")["data-role"], "only one title: the old one steps down"
  end

  test "joining a line with the one above merges the two" do
    open_sorter("Cake\n2 cups flour\n1 cup sugar\nMix everything in a big bowl\nUntil smooth.")
    assert_selector "[data-line-sorter-target=row]", count: 5

    tap_line("Until smooth.", "Join with the line above")

    assert_selector "[data-line-sorter-target=row]", count: 4
    assert_selector "input[data-text-input][value='Mix everything in a big bowl Until smooth.']", visible: :all
    click_button "Build recipe"
    assert_selector "textarea[aria-label=Step]", text: "Mix everything in a big bowl Until smooth."
  end

  test "only one tray is open at a time, and the first line has no join button" do
    open_sorter("Cake\n2 cups flour\n1 cup sugar\nMix everything in a big bowl\nUntil smooth.")

    row("2 cups flour").find("button[aria-expanded]").click
    assert_selector "[data-tray]:not([hidden])", count: 1
    row("1 cup sugar").find("button[aria-expanded]").click
    assert_selector "[data-tray]:not([hidden])", count: 1
    within(row("Cake")) do
      find("button[aria-expanded]").click
      assert_no_button "Join with the line above"
    end
  end

  test "the import page explains how to scan, and an empty import goes back with a message" do
    visit new_recipes_import_path
    assert_text "On an iPhone or iPad"
    assert_text "Scan Text"
    assert_text "On a computer"

    within("form[data-controller=paste]") { click_button "Import" }
    assert_current_path new_recipes_import_path
    assert_text "Enter a web address or paste the recipe."
  end

  test "on a computer the box is ready for pasting" do
    on_desktop do
      visit new_recipes_import_path
      assert_equal "text", page.evaluate_script("document.activeElement.name")
    end
  end
end
