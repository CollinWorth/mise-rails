# The collection form: a name, a line about it, and whether it's public. `recipe_id` is carried along when the collection is made
# from a recipe's "add to a collection" sheet, so the recipe goes straight in.
class Components::CollectionForm < Components::Base
  def initialize(collection:, recipe_id: nil)
    @collection = collection
    @recipe_id = recipe_id
  end

  def view_template
    ActionForm(action: @collection.persisted? ? collection_path(@collection) : collections_path, method: @collection.persisted? ? :patch : :post) do
      Stack do
        ErrorMessages(record: @collection)
        input(type: :hidden, name: "recipe_id", value: @recipe_id) if @recipe_id
        Field(label: "Name", name: "collection[name]", value: @collection.name, maxlength: 60, required: true, placeholder: "Weeknight dinners")
        TextAreaField(label: "About (optional)", name: "collection[description]", value: @collection.description, rows: 3, maxlength: 300)
        Row(gap: :sm, class: "items-start flex-nowrap") do
          input(type: :hidden, name: "collection[public]", value: "0")
          Checkbox(id: "collection_public", name: "collection[public]", value: "1", checked: @collection.public?, class: "mt-1")
          Stack(gap: :sm) do
            FormFieldLabel(for: "collection_public") { "Public" }
            Text(size: "2", class: "text-muted-foreground") { "Shown on your profile, and anyone with the link can see the public recipes in it. Private recipes stay private." }
          end
        end
        Row do
          Button(type: :submit) { @collection.persisted? ? "Save collection" : "Create collection" }
          Link(href: @collection.persisted? ? collection_path(@collection) : collections_path, variant: :ghost) { "Cancel" }
        end
      end
    end
  end
end
