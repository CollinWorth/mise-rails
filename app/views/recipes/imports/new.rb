class Views::Recipes::Imports::New < Views::Base
  def view_template
    PageHeader(title: "Import a recipe")
    Text { "Review and edit the recipe before it's saved." }
    ActionForm(action: recipes_import_path) do
      Stack do
        Field(label: "Web address", name: "url", type: :url, placeholder: "https://")
        TextAreaField(label: "…or paste the recipe text", name: "text", rows: 10)
        Row do
          Button(type: :submit) { "Import" }
          Link(href: recipes_path, variant: :ghost) { "Cancel" }
        end
      end
    end
  end
end
