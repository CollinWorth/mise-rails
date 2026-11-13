class Components::RecipeGrid < Components::Base
  def initialize(recipes:, show_author: false, empty: "No recipes yet.")
    @recipes = recipes
    @show_author = show_author
    @empty = empty
  end

  def view_template
    return EmptyState(title: @empty) if @recipes.none?

    Grid(columns: 3) { @recipes.each { |recipe| RecipeCard(recipe:, show_author: @show_author) } }
  end
end
