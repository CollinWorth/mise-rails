require "application_system_test_case"

class SignInTest < ApplicationSystemTestCase
  test "signing in and out" do
    user = create_user(name: "Maria")

    sign_in_through_form(user)
    assert_text "My recipes"

    visit profile_path
    click_button "Sign out"
    assert_current_path new_session_path
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
end
