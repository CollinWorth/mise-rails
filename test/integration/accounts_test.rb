require "test_helper"

class AccountsTest < ActionDispatch::IntegrationTest
  test "the sign-up page is open to visitors" do
    get new_registration_path
    assert_response :success
    assert_select "input[name='user[email_address]']"
  end

  test "signing up creates the account, signs in, and goes to the recipes" do
    assert_difference "User.count", 1 do
      post registration_path, params: { user: { name: "Maria", email_address: "Maria@Example.com", password: "secret123" } }
    end

    assert_redirected_to recipes_path
    assert_equal "maria@example.com", User.last.email_address
    follow_redirect!
    assert_response :success
  end

  test "a sign-up with a short password or a taken email shows what's wrong and creates nothing" do
    create_user(name: "Taken", email: "taken@example.com")

    assert_no_difference "User.count" do
      post registration_path, params: { user: { name: "Maria", email_address: "taken@example.com", password: "123" } }
    end

    assert_response :unprocessable_content
    assert_select "[role=alert]", text: /Email address has already been taken/
    assert_select "[role=alert]", text: /Password is too short/
  end

  test "after signing in you land on the page you were stopped at" do
    cook = create_user
    get new_recipe_path
    assert_redirected_to new_session_path

    post session_path, params: { email_address: cook.email_address, password: "secret123" }
    assert_redirected_to new_recipe_url
  end

  test "an invalid profile edit shows the errors and keeps the old details" do
    cook = create_user(name: "Maria")
    sign_in cook

    patch profile_path, params: { user: { name: "", email_address: "not an email" } }

    assert_response :unprocessable_content
    assert_select "[role=alert]", text: /Name can't be blank/
    assert_equal "Maria", cook.reload.name
  end

  test "deleting the account needs the right password" do
    cook = create_user
    sign_in cook

    assert_no_difference "User.count" do
      delete profile_path, params: { password: "wrong" }
    end

    assert_redirected_to profile_path
    assert_equal "Incorrect password.", flash[:alert]
  end

  test "deleting the account removes the cook and everything of theirs, and signs them out" do
    cook = create_user
    create_recipe(cook, name: "Soup")
    sign_in cook

    assert_difference [ "User.count", "Recipe.count" ], -1 do
      delete profile_path, params: { password: "secret123" }
    end

    assert_redirected_to new_registration_path
    get recipes_path
    assert_redirected_to discover_path
  end
end
