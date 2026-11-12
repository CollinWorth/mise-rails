require "application_system_test_case"

class ReactionsTest < ApplicationSystemTestCase
  setup do
    @recipe = create_recipe(create_user(name: "Maria"), name: "Greek Salad")
    sign_in_through_form(create_user(name: "Sam"))
    visit recipe_path(@recipe)
  end

  test "clicking a star rates the recipe and clear removes it" do
    star_buttons = -> { all("button", text: "★").map { |button| button[:class].split.include?("bg-primary") } }
    assert_equal [ false, false, false ], star_buttons.call

    all("button", text: "★")[1].click
    assert_selector "button", text: "Clear"
    assert_equal [ true, true, false ], star_buttons.call
    assert_equal 2, @recipe.reload.average_rating

    click_button "Clear"
    assert_no_selector "button", text: "Clear"
    assert_equal [ false, false, false ], star_buttons.call
  end

  test "liking and unliking" do
    click_button "♡ 0"
    assert_button "♥ 1"
    click_button "♥ 1"
    assert_button "♡ 0"
  end

  test "posting a comment" do
    fill_in "comment[body]", with: "Looks great"
    click_button "Post"
    assert_text "Looks great"
    assert_text "Comments (1)"
  end

  test "buttons keep the scroll position instead of jumping to the top" do
    tall = create_recipe(@recipe.user, name: "Long Recipe", ingredients: Array.new(40) { |n| { name: "ingredient #{n}" } })
    visit recipe_path(tall)
    page.execute_script("window.scrollTo(0, document.body.scrollHeight)")
    before = page.evaluate_script("Math.round(scrollY)")
    assert_operator before, :>, 300

    click_button "♡ 0"
    assert_button "♥ 1"
    assert_in_delta before, page.evaluate_script("Math.round(scrollY)"), 100
  end
end
