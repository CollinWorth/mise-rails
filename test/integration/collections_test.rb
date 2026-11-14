require "test_helper"

class CollectionsTest < ActionDispatch::IntegrationTest
  setup do
    @cook = create_user(name: "Maria")
    @other = create_user(name: "Sam")
    @soup = create_recipe(@cook, name: "Soup")
    @theirs = create_recipe(@other, name: "Their stew")
    @secret = create_recipe(@other, name: "Their secret", public: false)
    sign_in @cook
  end

  test "the list shows your collections with their size, and an empty one invites you to make the first" do
    get collections_path
    assert_select "h3", text: "No collections yet"

    @cook.collections.create!(name: "Weeknight").add(@soup)
    @other.collections.create!(name: "Not yours", public: true)
    get collections_path
    assert_select "a", text: "Weeknight"
    assert_select "a", text: "Not yours", count: 0
    assert_match(/1 recipe/, response.body)
    assert_select "a[href=?]", new_collection_path, text: "New collection"
  end

  test "making a collection, then renaming and making it public" do
    assert_difference -> { @cook.collections.count }, 1 do
      post collections_path, params: { collection: { name: "Weeknight", description: "Quick ones", public: "0" } }
    end
    collection = @cook.collections.last
    assert_redirected_to collection_path(collection)
    assert_not collection.public?

    patch collection_path(collection), params: { collection: { name: "Weeknights", public: "1" } }
    assert_redirected_to collection_path(collection)
    assert_equal [ "Weeknights", true ], collection.reload.values_at(:name, :public)
  end

  test "a name that is missing or taken shows why and saves nothing" do
    @cook.collections.create!(name: "Weeknight")
    assert_no_difference -> { Collection.count } do
      post collections_path, params: { collection: { name: "weeknight" } }
      assert_response :unprocessable_content
      assert_match(/already been taken/, response.body)

      post collections_path, params: { collection: { name: "" } }
      assert_response :unprocessable_content
    end
  end

  test "the add sheet lists your collections, shows which hold the recipe, and only opens in a frame" do
    @cook.collections.create!(name: "Weeknight").add(@soup)
    @cook.collections.create!(name: "Guests")

    get recipe_collections_path(@soup)
    assert_redirected_to recipe_path(@soup)

    get recipe_collections_path(@soup), headers: modal_headers
    assert_select "turbo-frame#modal"
    assert_select "button[aria-pressed=true]", text: /Weeknight/
    assert_select "button[aria-pressed=false]", text: /Guests/
    assert_select "form[action=?] input[name=collection\\[name\\]]", collections_path
  end

  test "adding a recipe puts it in, adding again changes nothing, and removing takes it out" do
    collection = @cook.collections.create!(name: "Weeknight")

    post collection_recipes_path(collection), params: { recipe_id: @soup.id }
    assert_redirected_to recipe_path(@soup)
    assert_match(/Added Soup to Weeknight/, flash[:notice])

    assert_no_difference -> { CollectionRecipe.count } do
      post collection_recipes_path(collection), params: { recipe_id: @soup.id }
    end

    delete collection_recipe_path(collection, @soup)
    assert_not collection.includes?(@soup)
    assert_match(/Took Soup out of Weeknight/, flash[:notice])
  end

  test "a public recipe of someone else's can be added, a private one is not found" do
    collection = @cook.collections.create!(name: "Ideas")
    post collection_recipes_path(collection), params: { recipe_id: @theirs.id }
    assert collection.includes?(@theirs)

    post collection_recipes_path(collection), params: { recipe_id: @secret.id }
    assert_response :not_found
    assert_not collection.includes?(@secret)
  end

  test "starting a collection from a recipe's sheet puts the recipe straight in" do
    assert_difference -> { @cook.collections.count }, 1 do
      post collections_path, params: { collection: { name: "Soups" }, recipe_id: @soup.id }
    end
    assert_redirected_to recipe_path(@soup)
    assert_match(/Added Soup to Soups/, flash[:notice])
    assert @cook.collections.find_by(name: "Soups").includes?(@soup)
  end

  test "a collection page shows its recipes to the owner with a way to remove each, and its recipe page lists where it is" do
    collection = @cook.collections.create!(name: "Weeknight")
    collection.add(@soup)

    get collection_path(collection)
    assert_select "h1", text: "Weeknight"
    assert_select "a", text: "Soup"
    assert_select "button", text: "Remove from collection"
    assert_select "a", text: "Edit"
    assert_select "button", text: "Delete"
    assert_select "[data-controller=share]", count: 0, message: "a private collection can't be shared"
    assert_match(/Only you can see this collection/, response.body)

    get recipe_path(@soup)
    assert_select "a[href=?]", collection_path(collection), text: "Weeknight"
    assert_select "a[href=?][data-turbo-frame=modal]", recipe_collections_path(@soup), text: /Add to a collection/
  end

  test "a public collection can be opened by anyone, and shows only what they may see, with a share button for the owner" do
    collection = @cook.collections.create!(name: "Shared", public: true)
    private_recipe = create_recipe(@cook, name: "Hidden one", public: false)
    [ @soup, private_recipe ].each { |recipe| collection.add(recipe) }

    get collection_path(collection)
    assert_select "[data-controller=share][data-share-url-value=?]", collection_url(collection)

    delete session_path
    get collection_path(collection)
    assert_response :success
    assert_select "a", text: "Soup"
    assert_no_match(/Hidden one/, response.body)
    assert_select "button", text: "Remove from collection", count: 0
    assert_select "a", text: "Edit", count: 0
  end

  test "a private collection is not found by anyone else, signed in or not" do
    collection = @cook.collections.create!(name: "Mine")
    sign_in @other
    get collection_path(collection)
    assert_response :not_found

    delete session_path
    get collection_path(collection)
    assert_response :not_found
  end

  test "you can't edit, delete or add to someone else's collection" do
    theirs = @other.collections.create!(name: "Theirs", public: true)

    get edit_collection_path(theirs)
    assert_response :not_found
    patch collection_path(theirs), params: { collection: { name: "Mine now" } }
    assert_response :not_found
    delete collection_path(theirs)
    assert_response :not_found
    post collection_recipes_path(theirs), params: { recipe_id: @soup.id }
    assert_response :not_found
    assert_equal "Theirs", theirs.reload.name
  end

  test "deleting a collection keeps the recipes" do
    collection = @cook.collections.create!(name: "Temp")
    collection.add(@soup)
    delete collection_path(collection)
    assert_redirected_to collections_path
    assert Recipe.exists?(@soup.id)
  end

  test "public collections are on the cook's profile, private ones are not" do
    @cook.collections.create!(name: "Shown", public: true)
    @cook.collections.create!(name: "Hidden")

    sign_in @other
    get user_path(@cook)
    assert_select "h3", text: "Collections"
    assert_select "a", text: "Shown"
    assert_select "a", text: "Hidden", count: 0
  end

  test "collections need a signed-in cook" do
    delete session_path
    get collections_path
    assert_redirected_to new_session_path
    post collections_path, params: { collection: { name: "x" } }
    assert_redirected_to new_session_path
  end
end
