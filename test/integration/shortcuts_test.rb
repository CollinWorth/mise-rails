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

    assert_select "p", text: /shortcuts\/grocery_items/
    assert_select "p", text: /shortcuts\/recipe_imports/

    get shortcut_key_path # gone on the next visit
    assert_redirected_to profile_path
  end
end

class ShortcutRecipeImportsTest < ActionDispatch::IntegrationTest
  PAGE = <<~HTML
    <html><head><script type="application/ld+json">
      {"@type":"Recipe","name":"Lentil Soup","recipeIngredient":["1 cup lentils","2 carrots"],"recipeInstructions":["Simmer.","Serve."]}
    </script></head></html>
  HTML

  setup do
    @cook = create_user(name: "Maria")
    @key = @cook.regenerate_shortcut_token
  end

  def share(url, key: @key, page: PAGE)
    fetched = Struct.new(:body).new(page)
    RemoteFetch.stub(:get, fetched) do
      post shortcuts_recipe_imports_path, params: { url: }.to_json, headers: { "Content-Type" => "application/json", "Authorization" => "Bearer #{key}" }
    end
  end

  test "a shared page becomes a private recipe of yours, and the answer says where it is" do
    share "https://example.com/lentil-soup"

    assert_response :created
    recipe = @cook.recipes.sole
    assert_equal [ "Lentil Soup", false, "https://example.com/lentil-soup" ], [ recipe.name, recipe.public, recipe.source_url ]
    assert_equal 2, recipe.ingredients.count
    assert_equal "Saved “Lentil Soup” to your recipes.", response.parsed_body["message"]
    assert_equal recipe_url(recipe), response.parsed_body["url"]
  end

  test "the title the share sheet sends with the address is ignored" do
    share "Great soup! https://example.com/lentil-soup?ref=share"
    assert_response :created
    assert_equal "https://example.com/lentil-soup?ref=share", @cook.recipes.sole.source_url
  end

  test "sharing the same page twice saves it once" do
    share "https://example.com/lentil-soup"
    share "https://example.com/lentil-soup"

    assert_response :ok
    assert_equal 1, @cook.recipes.count
    assert_match(/already have/, response.parsed_body["message"])
  end

  test "a page with no recipe says so and saves nothing" do
    share "https://example.com/blog", page: "<html><body>Just a post</body></html>"
    assert_response :unprocessable_content
    assert_match(/No recipe found/, response.parsed_body["message"])
    assert_equal 0, @cook.recipes.count
  end

  test "an address that isn't allowed says why" do
    refuse = ->(*) { raise RemoteFetch::Refused, "That address isn't allowed." }
    RemoteFetch.stub(:get, refuse) do
      post shortcuts_recipe_imports_path, params: { url: "http://10.0.0.1/x" }.to_json, headers: { "Content-Type" => "application/json", "Authorization" => "Bearer #{@key}" }
    end
    assert_response :unprocessable_content
    assert_equal "That address isn't allowed.", response.parsed_body["message"]
  end

  test "nothing that looks like an address, or a wrong key, saves anything" do
    share "just some words"
    assert_response :unprocessable_content

    share "https://example.com/lentil-soup", key: "nope"
    assert_response :unauthorized
    assert_equal 0, @cook.recipes.count
  end
end
