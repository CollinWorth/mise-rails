# One row in the "add to a collection" sheet: tap it to put the recipe in that collection, or take it out if it's already there.
class Components::CollectionChoice < Components::Base
  def initialize(collection:, recipe:)
    @collection = collection
    @recipe = recipe
  end

  def view_template
    member = @collection.includes?(@recipe)
    ActionForm(action: member ? collection_recipe_path(@collection, @recipe) : collection_recipes_path(@collection), method: member ? :delete : :post, top: true) do
      input(type: :hidden, name: "recipe_id", value: @recipe.id)
      Button(type: :submit, variant: member ? :secondary : :outline, class: "h-auto min-h-12 w-full justify-between gap-3 whitespace-normal break-words py-3 text-left", aria: { pressed: member.to_s }) do
        span { @collection.name }
        span(class: "flex shrink-0 items-center gap-1 text-sm text-muted-foreground") do
          if member
            Icon(:check, class: "size-4 text-brand-2")
            plain "In it"
          else
            plain "Add"
          end
        end
      end
    end
  end
end
