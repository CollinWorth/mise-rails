require "application_system_test_case"

class SignInSystemTest < ApplicationSystemTestCase
  test "signing in and out" do
    user = create_user(name: "Maria")

    sign_in_through_form(user)
    assert_text "My recipes"

    visit profile_path
    click_button "Sign out"
    assert_current_path root_path
  end

  test "wrong password shows an error and stays on the form" do
    user = create_user(name: "Maria")

    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "nope"
    click_button "Sign in"

    assert_current_path new_session_path
    assert_text "Try another email address or password"
  end

  test "the account page's buttons fit their labels instead of stretching across the page" do
    sign_in_through_form(create_user(name: "Maria"))

    on_desktop do
      visit profile_path
      [ "Save", "Update password", "Sign out", "Delete account" ].each do |label|
        width = find_button(label, match: :first).native.size.width
        assert_operator width, :<, 200, "#{label} is #{width}px wide"
      end
      assert_operator find("h1").find(:xpath, "..").native.size.width, :<=, 700, "the page is a narrow column"
    end
  end

  test "forgetting the password: ask for a link, follow it, choose a new one, sign in with it" do
    user = create_user(name: "Maria")

    visit new_session_path
    click_link "Forgot your password?"
    fill_in "Email", with: user.email_address
    click_button "Send the link"
    assert_text "a link to choose a new password is on its way"

    visit edit_password_reset_path(user.password_reset_token)
    fill_in "New password", with: "brandnew1"
    click_button "Update password"
    assert_text "Password updated"

    fill_in "Email", with: user.email_address
    fill_in "Password", with: "brandnew1"
    click_button "Sign in"
    assert_current_path recipes_path
  end
end
