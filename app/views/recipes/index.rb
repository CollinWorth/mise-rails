class Views::Recipes::Index < Views::Base
  def initialize(recipes:, pagy:, query:)
    @recipes = recipes
    @pagy = pagy
    @query = query
  end

  def view_template
    PageHeader(title: "My recipes") do
      Link(href: new_recipes_import_path, variant: :outline) { "Import" }
      Link(href: new_recipe_path, variant: :primary) { "New recipe" }
    end
    SearchForm(action: recipes_path, query: @query, placeholder: "Search my recipes")
    RecipeGrid(recipes: @recipes, empty: "No recipes yet. Add one or import it from a web page.")
    Pager(pagy: @pagy)
  end
end
