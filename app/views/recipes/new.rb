class Views::Recipes::New < Views::Base
  def initialize(recipe:)
    @recipe = recipe
  end

  def view_template
    PageHeader(title: "New recipe")
    RecipeForm(recipe: @recipe)
  end
end
