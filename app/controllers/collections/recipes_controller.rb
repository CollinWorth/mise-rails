# Putting a recipe in a collection, and taking it out. Only the collection's owner can.
class Collections::RecipesController < ApplicationController
  before_action :set_collection

  def create
    recipe = Recipe.visible_to(Current.user).find(params[:recipe_id])
    @collection.add(recipe)
    redirect_back_or_to recipe, notice: "Added #{recipe.name} to #{@collection.name}.", status: :see_other
  end

  def destroy
    recipe = Recipe.find(params[:id])
    @collection.remove(recipe)
    redirect_back_or_to @collection, notice: "Took #{recipe.name} out of #{@collection.name}.", status: :see_other
  end

  private
    def set_collection = @collection = Current.user.collections.find(params[:collection_id])
end
