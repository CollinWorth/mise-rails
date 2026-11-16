require "test_helper"

class ShortcutsTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    @key = @cook.regenerate_shortcut_token
  end

  def add(text, key: @key)
    post shortcuts_grocery_items_path, params: { text: }.to_json, headers: { "Content-Type" => "application/json", "Authorization" => "Bearer #{key}", "User-Agent" => "Shortcuts/1.0 CFNetwork" }
  end

  test "the key adds what was said to your list and says what it did" do
    add "milk, 2 lb chicken thighs, 3 bananas, 1 1/2 cup rice"

    assert_response :created
    assert_equal "Added milk, chicken thighs, bananas, and rice to your grocery list.", response.parsed_body["message"]
    items = @cook.grocery_list.items.index_by(&:name)
    assert_equal [ nil, nil ], [ items["milk"].quantity, items["milk"].unit ]
    assert_equal [ "2", "lb" ], [ items["chicken thighs"].quantity, items["chicken thighs"].unit ]
    assert_equal [ "3", nil ], [ items["bananas"].quantity, items["bananas"].unit ]
    assert_equal [ "1 1/2", "cup" ], [ items["rice"].quantity, items["rice"].unit ]
    assert_equal "produce", items["bananas"].category
  end

  test "something already on the list is not added twice, and is put back if it was ticked" do
    @cook.grocery_list.items.create!(name: "milk", checked: true)
    add "Milk"
    assert_equal 1, @cook.grocery_list.items.count
    assert_not @cook.grocery_list.items.first.checked
  end

  test "a wrong, missing or replaced key is turned away and adds nothing" do
    add "milk", key: "nope"
    assert_response :unauthorized

    post shortcuts_grocery_items_path, params: { text: "milk" }.to_json, headers: { "Content-Type" => "application/json" }
    assert_response :unauthorized

    @cook.regenerate_shortcut_token
    add "milk"
    assert_response :unauthorized
    assert_equal 0, @cook.grocery_list.items.count
  end

  test "an empty request says it heard nothing" do
    add "  ,  "
    assert_response :unprocessable_content
  end

  test "the key is made on the profile page, shown once, and only its digest is kept" do
    sign_in @cook
    get profile_path
    assert_select "form[action=?] button", shortcut_key_path, text: "Make my Shortcut key"

    post shortcut_key_path
    assert_redirected_to shortcut_key_path
    follow_redirect!
    assert_response :success
    shown = css_select("input[aria-label='Shortcut key']").first["value"]
    assert_equal @cook.reload, User.find_by_shortcut_token(shown)
    assert_not_equal shown, @cook.shortcut_token_digest

    get shortcut_key_path # gone on the next visit
    assert_redirected_to profile_path
  end
end
