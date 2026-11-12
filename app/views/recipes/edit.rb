class Views::Recipes::Edit < Views::Base
  def initialize(recipe:)
    @recipe = recipe
  end

  def view_template
    PageHeader(title: "Edit recipe")
    RecipeForm(recipe: @recipe)
  end
end
