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
end
