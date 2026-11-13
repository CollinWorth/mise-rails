require "application_system_test_case"

# Journeys use the app like a person: only links, buttons and fields on the screen, and the database only to check what
# was kept at the end. Shared steps live here so each journey reads as a story.
class JourneyTestCase < ApplicationSystemTestCase
  def sign_up(name:, email:)
    click_link "Get started", match: :first
    fill_in "Name", with: name
    fill_in "Email", with: email
    fill_in "Password (6+ characters)", with: "secret123"
    click_button "Sign up"
    assert_current_path recipes_path
  end

  def sign_out
    click_button "Account menu"
    click_button "Sign out"
    assert_current_path root_path
  end

  def sign_in(email)
    visit new_session_path
    fill_in "Email", with: email
    fill_in "Password", with: "secret123"
    click_button "Sign in"
    assert_current_path recipes_path
  end

  def tab(name) = within("nav", text: /Recipes/, match: :first) { click_link name }
end
