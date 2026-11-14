class Views::Collections::Show < Views::Base
  def initialize(collection:, recipes:, pagy:)
    @collection = collection
    @recipes = recipes
    @pagy = pagy
  end

  def page_meta
    cover = @recipes.find { |recipe| share_image(recipe) }
    count = @pagy.count
    { title: @collection.name, description: [ "A collection by #{@collection.user.name}", "#{count} #{'recipe'.pluralize(count)}", @collection.description ].compact.join(" · "),
      image: (share_image(cover) if cover), url: collection_url(@collection), noindex: !@collection.public? }
  end

  def view_template
    PageHeader(title: @collection.name) { actions }
    Row(gap: :sm, class: "text-sm text-muted-foreground") do
      Avatar(name: @collection.user.name, size: "size-6 text-xs")
      TextLink(href: user_path(@collection.user), class: "font-medium text-foreground") { @collection.user.name }
      Text(as: "span", size: "2") { "#{@pagy.count} #{'recipe'.pluralize(@pagy.count)}" }
      Badge(variant: :outline) { "Private" } unless @collection.public?
    end
    Text(class: "max-w-2xl") { @collection.description } if @collection.description
    private_hint if owner? && !@collection.public?
    owner? ? owner_grid : RecipeGrid(recipes: @recipes, show_author: true, empty: "Nothing to show here yet.")
    Pager(pagy: @pagy)
  end

  private
    def owner? = Current.user == @collection.user

    def actions
      if @collection.public?
        Button(type: :button, variant: :outline, data: { controller: "share", action: "share#share", share_title_value: @collection.name, share_url_value: collection_url(@collection) }) do
          Icon(:share, class: "size-4")
          plain "Share"
        end
      end
      return unless owner?

      Link(href: edit_collection_path(@collection), variant: :outline) { "Edit" }
      ButtonTo(action: collection_path(@collection), method: :delete, variant: :ghost, data: { turbo_confirm: "Delete the collection #{@collection.name}? The recipes in it stay." }) { "Delete" }
    end

    def private_hint
      Alert do
        AlertDescription do
          plain "Only you can see this collection. "
          TextLink(href: edit_collection_path(@collection)) { "Make it public" }
          plain " to share it with a link."
        end
      end
    end

    # The owner's view of the recipes: each card has a way to take the recipe out.
    def owner_grid
      return EmptyState(title: "This collection is empty", text: "Open a recipe, tap the ⋯ menu and choose “Add to a collection”.", icon: :folder) { Link(href: recipes_path, variant: :primary) { "Pick recipes" } } if @recipes.none?

      Grid(columns: 3) do
        @recipes.each_with_index do |recipe, index|
          Stack(gap: :sm) do
            RecipeCard(recipe:, show_author: true, eager: index < Components::RecipeGrid::EAGER)
            ButtonTo(action: collection_recipe_path(@collection, recipe), method: :delete, variant: :ghost, size: :sm, button_class: "text-muted-foreground") { "Remove from collection" }
          end
        end
      end
    end
end
