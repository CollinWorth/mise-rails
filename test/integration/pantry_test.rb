require "test_helper"

class PantryTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    sign_in @cook
  end

  test "the pantry page lists your items and offers suggestions you don't have yet" do
    @cook.pantry_items.create!(name: "salt")
    get pantry_items_path

    assert_response :success
    assert_select "p", text: "salt"
    assert_select "button", text: "+ salt", count: 0
    assert_select "button", text: "+ olive oil"
  end

  test "adding an item, and a friendly message for a duplicate" do
    post pantry_items_path, params: { pantry_item: { name: "Flour" } }
    assert_equal [ "flour" ], @cook.pantry_keys

    post pantry_items_path, params: { pantry_item: { name: "flours" } }, headers: { "HTTP_REFERER" => pantry_items_url }
    assert_redirected_to pantry_items_url
    assert_match(/already in your pantry/, flash[:alert])
    assert_equal 1, @cook.pantry_items.count
  end

  test "removing an item" do
    item = @cook.pantry_items.create!(name: "salt")
    delete pantry_item_path(item)
    assert_equal 0, @cook.pantry_items.count
  end

  test "you can't touch someone else's pantry" do
    theirs = create_user(name: "Other").pantry_items.create!(name: "salt")
    delete pantry_item_path(theirs)
    assert_response :not_found
    assert PantryItem.exists?(theirs.id)
  end

  test "pantry needs signing in" do
    delete session_path
    get pantry_items_path
    assert_redirected_to new_session_path
  end
end
