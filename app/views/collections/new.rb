class Views::Collections::New < Views::Base
  def initialize(collection:, recipe_id: nil)
    @collection = collection
    @recipe_id = recipe_id
  end

  def view_template
    Narrow do
      PageHeader(title: "New collection")
      CollectionForm(collection: @collection, recipe_id: @recipe_id)
    end
  end
end
