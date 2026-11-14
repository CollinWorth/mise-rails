# A collection on a list: a photo from one of its recipes (or a colored tile), its name and size. The whole card opens it.
class Components::CollectionCard < Components::Base
  def initialize(collection:)
    @collection = collection
  end

  def view_template
    viewer = Current.user
    recipes = @collection.recipes_for(viewer)
    cover = @collection.cover_recipe(viewer) || recipes.first
    Card(class: "group relative overflow-hidden transition duration-200 hover:-translate-y-0.5 hover:shadow-md") do
      div(class: "overflow-hidden") do
        cover ? RecipeImage(recipe: cover, class: "transition duration-300 group-hover:scale-105") : empty_cover
      end
      CardHeader(class: "gap-1 p-4 pb-2") do
        CardTitle(class: "text-base leading-snug") { TextLink(href: collection_path(@collection), class: "font-semibold text-foreground after:absolute after:inset-0") { @collection.name } }
      end
      CardContent(class: "p-4 pt-0") do
        Row(gap: :sm, class: "text-xs text-muted-foreground") do
          span { "#{recipes.count} #{'recipe'.pluralize(recipes.count)}" }
          Badge(variant: :outline) { "Private" } unless @collection.public?
        end
      end
    end
  end

  private
    def empty_cover
      div(class: "flex aspect-video w-full items-center justify-center bg-gradient-to-br from-primary/20 to-brand-2/20 text-primary", aria_hidden: "true") { Icon(:folder, class: "size-10") }
    end
end
