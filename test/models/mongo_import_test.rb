require "test_helper"
require "bson"

class MongoImportTest < ActiveSupport::TestCase
  setup do
    @dir = Pathname(Dir.mktmpdir)
    @collin, @maria, @recipe, @copy = %w[a b c d].map { |letter| BSON::ObjectId.from_string(letter * 24) }
    digest = BCrypt::Password.create("secret123").to_s.sub("$2a$", "$2b$")

    dump("users", { _id: @collin, name: "Collin", email: "Collin@Example.com", password: digest }, { _id: @maria, name: "Maria", email: "maria@example.com", password: digest })
    dump("recipes",
      { _id: @recipe, user_id: @collin.to_s, recipe_name: "Ramen", instructions: "Boil.\nServe.", prep_time: 5, cook_time: nil, servings: 2, cuisine: "Japanese", category: "", tags: "quick",
        is_public: true, is_modified: nil, original_recipe_id: "", image_url: "https://example.com/ramen.jpg",
        ingredients: [ { name: "For the broth", is_section: true }, { name: "Noodles", quantity: "200", unit: "g", is_section: false }, { name: "  ", quantity: "", unit: "" }, { name: "Egg", quantity: "1", unit: "" }, "Scallions" ] },
      { _id: @copy, user_id: @maria.to_s, recipe_name: "Ramen", is_public: false, is_modified: true, original_recipe_id: @recipe.to_s, ingredients: [] },
      { _id: BSON::ObjectId.new, user_id: "f" * 24, recipe_name: "Orphan", ingredients: [] })
    dump("comments", { _id: BSON::ObjectId.new, recipe_id: @recipe.to_s, user_id: @maria.to_s, text: "Tasty", parent_id: nil, created_at: Time.utc(2026, 4, 9) })
    dump("ratings", { _id: BSON::ObjectId.new, recipe_id: @recipe.to_s, user_id: @maria.to_s, rating: 2 }, { _id: BSON::ObjectId.new, recipe_id: @recipe.to_s, user_id: @maria.to_s, rating: 3 })
    dump("follows", { _id: BSON::ObjectId.new, follower_id: @maria.to_s, following_id: @collin.to_s })
    dump("mealPlans",
      { _id: BSON::ObjectId.new, user_id: @collin.to_s, recipe_id: @recipe.to_s, date: "2026-04-05", multiplier: 2 },
      { _id: BSON::ObjectId.new, user_id: @collin.to_s, recipe_id: BSON::ObjectId.new.to_s, date: "2026-04-06" })
    dump("groceryLists",
      { _id: BSON::ObjectId.new, user_id: @collin.to_s, name: "My List", items: [ { name: "milk", quantity: "1", unit: "gallon", category: "dairy", checked: true }, { name: "mystery", category: "made-up" } ] },
      { _id: BSON::ObjectId.new, user_id: @collin.to_s, name: "My List", items: [ { name: "eggs", quantity: "12" } ] })
  end

  teardown { FileUtils.remove_entry(@dir) }

  test "loads people, recipes with ingredients, and everything that hangs off them" do
    report = MongoImport.new(@dir, images: false).run

    assert_equal %w[Collin Maria], User.order(:id).pluck(:name)
    assert_equal "collin@example.com", User.first.email_address
    assert User.first.authenticate("secret123"), "old password hashes keep working"

    ramen = Recipe.find_by!(name: "Ramen", user: User.first)
    assert ramen.public?
    assert_nil ramen.category
    assert_equal [ "For the broth", "Noodles", "Egg", "Scallions" ], ramen.ingredients.map(&:name)
    assert_equal [ true, false, false, false ], ramen.ingredients.map(&:section)
    assert_equal [ 2 ], ramen.ratings.pluck(:value), "a second rating by the same person is dropped"
    assert_equal 1, Comment.count
    assert_equal Time.utc(2026, 4, 9), Comment.first.created_at
    assert_equal [ [ User.second.id, User.first.id ] ], Follow.pluck(:follower_id, :followed_id)
    assert_equal 2, PlannedMeal.first.multiplier

    assert_includes report.skipped.join, "Orphan"
    assert_includes report.skipped.join, "recipe was deleted"
  end

  test "a saved copy points back at the original" do
    MongoImport.new(@dir, images: false).run

    copy = Recipe.find_by!(user: User.second, name: "Ramen")
    assert_equal Recipe.find_by!(user: User.first, name: "Ramen"), copy.original
    assert copy.modified?
  end

  test "several grocery lists become one, with unknown aisles filed under other" do
    MongoImport.new(@dir, images: false).run

    items = User.first.grocery_list.items.index_by(&:name)
    assert_equal %w[eggs milk mystery], items.keys.sort
    assert items["milk"].checked?
    assert_equal "dairy", items["milk"].category
    assert_equal "dairy", items["eggs"].category, "guessed from the name"
    assert_equal User.count, GroceryList.count, "one list per person"
  end

  test "replaces whatever was there and can run twice" do
    create_recipe(create_user(name: "Old"), name: "Left over")

    2.times { MongoImport.new(@dir, images: false).run }

    assert_equal %w[Collin Maria], User.order(:id).pluck(:name)
    assert_nil Recipe.find_by(name: "Left over")
    assert_equal 3 - 1, Recipe.count
  end

  test "downloads photos, and skips ones that are not images" do
    photo = Struct.new(:body, :content_type)
    fetched = ->(url, **) { url.end_with?("ramen.jpg") ? photo.new(file_fixture("dish.jpg").binread, "image/jpeg") : raise(RemoteFetch::Refused) }

    RemoteFetch.stub :get, fetched do
      MongoImport.new(@dir).run
    end

    assert Recipe.find_by!(user: User.first, name: "Ramen").image.attached?
    assert_not Recipe.find_by!(user: User.second, name: "Ramen").image.attached?
  end

  test "photos uploaded to the old server come from its uploads folder" do
    uploads = Pathname(Dir.mktmpdir)
    FileUtils.cp(file_fixture("dish.jpg"), uploads.join("abc.jpg"))
    dump("recipes", { _id: @recipe, user_id: @collin.to_s, recipe_name: "Ramen", image_url: "https://old.example.com/api/uploads/abc.jpg", ingredients: [] })

    MongoImport.new(@dir, uploads:).run

    assert Recipe.find_by!(name: "Ramen").image.attached?
  ensure
    FileUtils.remove_entry(uploads)
  end

  test "an uploads folder does not get in the way of photos hosted elsewhere" do
    uploads = Pathname(Dir.mktmpdir)
    photo = Struct.new(:body, :content_type)

    RemoteFetch.stub :get, photo.new(file_fixture("dish.jpg").binread, "image/jpeg") do
      MongoImport.new(@dir, uploads:).run
    end

    assert Recipe.find_by!(user: User.first, name: "Ramen").image.attached?
  ensure
    FileUtils.remove_entry(uploads)
  end

  private
    def dump(collection, *documents)
      File.binwrite(@dir.join("#{collection}.bson"), documents.map { |doc| doc.to_bson.to_s }.join)
    end


  test "the report lists the counts and groups what was skipped by reason" do
    dump("mealPlans",
      { _id: BSON::ObjectId.new, user_id: @collin.to_s, recipe_id: BSON::ObjectId.new.to_s, date: "2026-04-06" },
      { _id: BSON::ObjectId.new, user_id: @collin.to_s, recipe_id: BSON::ObjectId.new.to_s, date: "2026-04-07" })

    text = MongoImport.new(@dir, images: false).run.to_s

    assert_match(/^2 users$/, text)
    assert_match(/^skipped 2x a planned meal \(recipe was deleted\)$/, text)
  end

  test "a photo address that can't be fetched leaves the recipe without one" do
    dump("recipes", { _id: @recipe, user_id: @collin.to_s, recipe_name: "Ramen", image_url: "https://example.com/gone.jpg", ingredients: [] })
    refuse = ->(*) { raise RemoteFetch::Refused, "no" }

    RemoteFetch.stub(:get, refuse) { MongoImport.new(@dir).run }

    assert_not Recipe.find_by!(name: "Ramen").image.attached?
  end

  test "a photo address that isn't a web address is ignored" do
    dump("recipes", { _id: @recipe, user_id: @collin.to_s, recipe_name: "Ramen", image_url: "not a url at all", ingredients: [] })
    uploads = Pathname(Dir.mktmpdir)

    MongoImport.new(@dir, uploads:).run

    assert_not Recipe.find_by!(name: "Ramen").image.attached?
  ensure
    FileUtils.remove_entry(uploads) if uploads
  end

  # --- the import:mongo task around it ---

  def run_task(env = {})
    require "rake"
    Rails.application.load_tasks unless Rake::Task.task_defined?("import:mongo")
    old = env.keys.to_h { |key| [ key, ENV[key] ] }
    env.each { |key, value| ENV[key] = value }
    Rake::Task["import:mongo"].reenable
    capture_io { Rake::Task["import:mongo"].invoke }.first
  ensure
    old.each { |key, value| value ? ENV[key] = value : ENV.delete(key) }
  end

  test "the task needs a dump folder, and a real one" do
    assert_raises(SystemExit) { run_task("DIR" => nil) }
    assert_raises(SystemExit) { run_task("DIR" => "/no/such/folder") }
  end

  test "the task prints what it loaded" do
    output = run_task("DIR" => @dir.to_s, "IMAGES" => "0")

    assert_match(/^2 users$/, output)
    assert_equal 2, User.count
  end

  test "in production the task won't wipe anything without CONFIRM=wipe" do
    Rails.stub(:env, ActiveSupport::StringInquirer.new("production")) do
      assert_raises(SystemExit) { run_task("DIR" => @dir.to_s, "CONFIRM" => nil) }
    end
    assert_equal 0, User.count
  end
end
