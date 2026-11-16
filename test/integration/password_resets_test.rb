require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "the sign-in page links to the forgot-password page" do
    get new_session_path
    assert_select "a[href='#{new_password_reset_path}']"
  end

  test "asking for a reset emails a working link to the account" do
    cook = create_user(email: "maria@example.com")

    assert_emails 1 do
      perform_enqueued_jobs { post password_resets_path, params: { email_address: "Maria@Example.com" } }
    end

    assert_redirected_to new_session_path
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "maria@example.com" ], mail.to
    token = mail.text_part.body.to_s[%r{password_resets/([^/\s]+)/edit}, 1]
    assert_equal cook, User.find_by_password_reset_token(token)
  end

  test "an unknown email gets the same answer and no email" do
    assert_no_emails do
      post password_resets_path, params: { email_address: "nobody@example.com" }
    end

    assert_redirected_to new_session_path
    assert_match(/If that email has an account/, flash[:notice])
  end

  test "the emailed link sets a new password and signs out old sessions" do
    cook = create_user
    sign_in cook
    assert_equal 1, cook.sessions.count

    patch password_reset_path(cook.password_reset_token), params: { password: "brandnew1" }

    assert_redirected_to new_session_path
    assert_equal 0, cook.sessions.count
    assert User.authenticate_by(email_address: cook.email_address, password: "brandnew1")
  end

  test "the form for the new password opens from the link" do
    cook = create_user
    get edit_password_reset_path(cook.password_reset_token)
    assert_response :success
    assert_select "input[name=password]"
  end

  test "a too-short new password is refused and says why" do
    cook = create_user
    patch password_reset_path(cook.password_reset_token), params: { password: "123" }
    assert_response :unprocessable_content
    assert_match(/too short/, response.body)
  end

  test "an expired or made-up link asks for a new one" do
    cook = create_user
    token = cook.password_reset_token
    travel 20.minutes do
      get edit_password_reset_path(token)
      assert_redirected_to new_password_reset_path
    end

    patch password_reset_path("nonsense"), params: { password: "brandnew1" }
    assert_redirected_to new_password_reset_path
  end

  test "a link stops working once the password has changed" do
    cook = create_user
    token = cook.password_reset_token
    cook.update!(password: "somethingelse")

    get edit_password_reset_path(token)
    assert_redirected_to new_password_reset_path
  end
end
