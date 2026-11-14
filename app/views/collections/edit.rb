class Views::Collections::Edit < Views::Base
  def initialize(collection:)
    @collection = collection
  end

  def view_template
    Narrow do
      PageHeader(title: "Edit collection")
      CollectionForm(collection: @collection)
    end
  end
end
