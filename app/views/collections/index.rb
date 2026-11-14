class Views::Collections::Index < Views::Base
  def initialize(collections:)
    @collections = collections
  end

  def view_template
    PageHeader(title: "Collections") do
      Link(href: recipes_path, variant: :outline) { "My recipes" }
      Link(href: new_collection_path, variant: :primary) { "New collection" }
    end
    if @collections.none?
      EmptyState(title: "No collections yet", text: "Group recipes your way: Weeknight, Guests, Baking. Add one from any recipe's menu.", icon: :folder) do
        Link(href: new_collection_path, variant: :primary) { "Make your first collection" }
      end
    else
      Grid(columns: 3) { @collections.each { |collection| CollectionCard(collection:) } }
    end
  end
end
