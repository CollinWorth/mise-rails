class Components::RecipeGrid < Components::Base
  EAGER = 6 # the first rows are on screen at once, so their photos shouldn't wait to be scrolled to

  def initialize(recipes:, show_author: false, empty: "No recipes yet.")
    @recipes = recipes
    @show_author = show_author
    @empty = empty
  end

  def view_template
    return EmptyState(title: @empty) if @recipes.none?

    Grid(columns: 3) { @recipes.each_with_index { |recipe, index| RecipeCard(recipe:, show_author: @show_author, eager: index < EAGER) } }
  end
end
