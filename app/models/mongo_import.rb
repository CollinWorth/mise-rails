require "bson"

# Loads a mongodump of the old Mise database (the cookindb folder of .bson files) into this app.
# Reads files only: it never connects to Mongo, so the live site is untouched.
# Run it with `bin/rails import:mongo DIR=...`; it replaces everything in the target database.
class MongoImport
  Report = Data.define(:counts, :skipped) do
    def to_s
      grouped = skipped.group_by { |reason| reason.sub(/ on \d{4}-\d\d-\d\d/, "") }.map { |reason, all| "skipped #{all.size}x #{reason}" }
      (counts.map { |name, count| "#{count} #{name}" } + grouped).join("\n")
    end
  end

  def initialize(dir, uploads: nil, images: true)
    @dir = Pathname(dir)
    @uploads = uploads && Pathname(uploads)
    @images = images
    @users = {}
    @recipes = {}
    @skipped = []
  end

  def run
    wipe
    ActiveRecord::Base.transaction do
      import_users
      import_recipes
      link_copies
      import_ratings
      import_comments
      import_follows
      import_planned_meals
      import_grocery_lists
    end
    Report.new(counts:, skipped: @skipped)
  end

  private
    def wipe
      Recipe.find_each { |recipe| recipe.image.purge }
      [ GroceryItemSource, GroceryItem, GroceryList, PantryItem, PlannedMeal, Comment, Like, Rating, Follow, Ingredient, Recipe, Session, User ].each(&:delete_all)
    end

    def counts
      { users: User, recipes: Recipe, ingredients: Ingredient, "recipe photos": ActiveStorage::Attachment, ratings: Rating, comments: Comment, follows: Follow, "planned meals": PlannedMeal, "grocery items": GroceryItem }
        .transform_values(&:count)
    end

    def import_users
      read("users").each do |doc|
        user = User.new(name: doc["name"], email_address: doc["email"], password_digest: doc["password"], created_at: doc["_id"].generation_time)
        save(user, "user #{doc["email"]}") { @users[doc["_id"].to_s] = user }
      end
    end

    def import_recipes
      read("recipes").each do |doc|
        user = @users[doc["user_id"].to_s] or next skip("recipe #{doc["recipe_name"].inspect} (author not found)")
        recipe = user.recipes.build(
          name: doc["recipe_name"], instructions: doc["instructions"], prep_time: doc["prep_time"], cook_time: doc["cook_time"], servings: doc["servings"],
          cuisine: doc["cuisine"].presence, category: doc["category"].presence, tags: doc["tags"].presence,
          public: doc["is_public"] == true, modified: doc["is_modified"] == true, created_at: created_at(doc)
        )
        Array(doc["ingredients"]).each_with_index do |row, position|
          row = { "name" => row } unless row.respond_to?(:keys) # very old recipes list plain names
          recipe.ingredients.build(name: row["name"].to_s.strip, quantity: row["quantity"].presence, unit: row["unit"].presence, section: row["is_section"] == true, position:) if row["name"].present?
        end
        attach_image(recipe, doc["image_url"])
        save(recipe, "recipe #{doc["recipe_name"].inspect}") { @recipes[doc["_id"].to_s] = recipe }
      end
    end

    # Saved copies point back at the recipe they came from.
    def link_copies
      read("recipes").each do |doc|
        original = @recipes[doc["original_recipe_id"].to_s] or next
        @recipes[doc["_id"].to_s]&.update_columns(original_id: original.id)
      end
    end

    def import_ratings
      read("ratings").each do |doc|
        user, recipe = @users[doc["user_id"].to_s], @recipes[doc["recipe_id"].to_s]
        next skip("a rating (user or recipe not found)") unless user && recipe

        save(Rating.new(user:, recipe:, value: doc["rating"], created_at: created_at(doc)), "a rating")
      end
    end

    def import_comments
      read("comments").each do |doc|
        user, recipe = @users[doc["user_id"].to_s], @recipes[doc["recipe_id"].to_s]
        next skip("a comment (user or recipe not found)") unless user && recipe

        save(Comment.new(user:, recipe:, body: doc["text"], created_at: created_at(doc)), "a comment")
      end
    end

    def import_follows
      read("follows").each do |doc|
        follower, followed = @users[doc["follower_id"].to_s], @users[doc["following_id"].to_s]
        next skip("a follow (user not found)") unless follower && followed

        save(Follow.new(follower:, followed:), "a follow")
      end
    end

    def import_planned_meals
      read("mealPlans").each do |doc|
        user, recipe = @users[doc["user_id"].to_s], @recipes[doc["recipe_id"].to_s]
        next skip("a planned meal on #{doc["date"]} (recipe was deleted)") unless user && recipe

        save(PlannedMeal.new(user:, recipe:, date: doc["date"], multiplier: doc["multiplier"] || 1), "a planned meal")
      end
    end

    # People could have several lists before; there is one list per person now, so they are combined.
    def import_grocery_lists
      read("groceryLists").each do |doc|
        user = @users[doc["user_id"].to_s] or next skip("a grocery list (user not found)")
        list = user.grocery_list || user.create_grocery_list!
        Array(doc["items"]).each do |row|
          category = GroceryItem::CATEGORIES.key?(row["category"]) ? row["category"] : "other"
          save(list.items.build(name: row["name"].to_s.strip, quantity: row["quantity"].presence, unit: row["unit"].presence, category:, checked: row["checked"] == true), "a grocery item")
        end
      end
    end

    def attach_image(recipe, url)
      return if url.blank? || !@images

      body, type, filename = local_upload(url) || remote_image(url)
      recipe.image.attach(io: StringIO.new(body), filename:, content_type: type) if body && Recipe::ACCEPTED_IMAGE_TYPES.include?(type) && body.bytesize <= Recipe::MAX_IMAGE_SIZE
    end

    # Photos uploaded to the old server live in its uploads folder.
    def local_upload(url)
      path = URI.parse(url).path.to_s
      return unless @uploads && path.match?(%r{\A(/api)?/uploads/})

      file = @uploads.join(File.basename(path))
      [ file.binread, Marcel::MimeType.for(file), file.basename.to_s ] if file.file?
    rescue URI::InvalidURIError
      nil
    end

    def remote_image(url)
      response = RemoteFetch.get(url)
      [ response.body, response.content_type.to_s.split(";").first, File.basename(URI.parse(url).path).presence || "image" ]
    rescue RemoteFetch::Refused, URI::InvalidURIError, SocketError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError
      nil
    end

    def save(record, label)
      if record.save
        yield if block_given?
        record
      else
        skip("#{label} (#{record.errors.full_messages.to_sentence})")
      end
    end

    def skip(what)
      @skipped << what
      nil
    end

    def created_at(doc) = doc["created_at"] || doc["_id"].generation_time

    # Each .bson file is a run of documents, each starting with its own byte length.
    def read(collection)
      path = @dir.join("#{collection}.bson")
      return [] unless path.file?

      File.open(path, "rb") do |io|
        documents = []
        while (header = io.read(4))
          documents << BSON::Document.from_bson(BSON::ByteBuffer.new(header + io.read(header.unpack1("V") - 4)))
        end
        documents
      end
    end
end
