# The "add to a collection" sheet on a recipe, loaded into the layout's `modal` Turbo Frame.
class Recipes::CollectionsController < ApplicationController
  include RecipeScoped

  def index
    render_sheet(fallback: recipe_path(@recipe)) { Views::Recipes::Collections::Index.new(recipe: @recipe, collections: Current.user.collections.order(:name).to_a) }
  end
end
