# The sheet behind a recipe's "Add to a collection": tap a collection to put the recipe in it (or take it out), or start a new one.
class Views::Recipes::Collections::Index < Views::Base
  def initialize(recipe:, collections:)
    @recipe = recipe
    @collections = collections
  end

  def view_template
    Sheet(title: "Add #{@recipe.name} to…") do
      Stack do
        if @collections.any?
          Stack(gap: :sm) { @collections.each { |collection| CollectionChoice(collection:, recipe: @recipe) } }
          Separator()
        end
        new_collection
      end
    end
  end

  private
    def new_collection
      ActionForm(action: collections_path, top: true) do
        Stack(gap: :sm) do
          Heading(level: 4) { "Or start a new one" }
          input(type: :hidden, name: "recipe_id", value: @recipe.id)
          Row(gap: :sm, class: "flex-nowrap") do
            Input(name: "collection[name]", placeholder: "Collection name", maxlength: 60, required: true, aria: { label: "New collection name" }, class: "min-w-0 flex-1")
            Button(type: :submit) { "Create" }
          end
        end
      end
    end
end
