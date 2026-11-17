require "application_system_test_case"

class WhatsNewSystemTest < ApplicationSystemTestCase
  setup do
    @cook = create_user(name: "Nina")
    @cook.update_column(:whats_new_seen_id, 0)
    sign_in_through_form @cook
  end

  test "first timers click through every card, then it never opens again" do
    entries = WhatsNew.entries
    assert_sheet_open
    assert_text entries.first.title
    assert_text "1 of #{entries.size}"
    assert_no_button "Back"

    (entries.size - 1).times { click_button "Next" }
    assert_text entries.last.title
    assert_text "#{entries.size} of #{entries.size}"
    click_button "Back"
    assert_text "#{entries.size - 1} of #{entries.size}"
    click_button "Next"
    click_button "Got it"
    assert_no_selector "[data-controller~=sheet]"
    assert_equal WhatsNew.latest_id, @cook.reload.whats_new_seen_id

    visit recipes_path
    assert_no_selector "[data-controller~=sheet]"
  end

  test "closing it straight away counts as read" do
    assert_sheet_open
    click_button "Close"
    assert_no_selector "[data-controller~=sheet]"
    assert_equal WhatsNew.latest_id, @cook.reload.whats_new_seen_id
    visit profile_path
    assert_no_selector "[data-controller~=sheet]"
  end

  test "a new announcement shows only itself, and the account page replays them all" do
    assert_sheet_open # the one from signing in marks everything read; wait for that before moving the marker back
    page.document.synchronize { raise Capybara::ExpectationNotMet, "not yet marked read" unless @cook.reload.whats_new_seen_id == WhatsNew.latest_id }
    @cook.update_column(:whats_new_seen_id, WhatsNew.latest_id - 1)
    visit recipes_path
    assert_sheet_open
    assert_text WhatsNew.entries.first.title
    assert_no_button "Next"
    click_button "Got it"

    visit profile_path
    click_link "See what's new"
    assert_sheet_open
    assert_text "1 of #{WhatsNew.entries.size}"
  end

  test "a card's link takes you to the feature" do
    click_link "Try it", match: :first
    assert_no_selector "[data-controller~=sheet]"
    assert_current_path(/\A#{Regexp.escape(URI(WhatsNew.entries.first.path).path)}/)
  end
end
