# Puts a recipe's ingredients (at the chosen scale) on your grocery list.
class Recipes::GroceryItemsController < ApplicationController
  include RecipeScoped

  def create
    factor = Recipe::SCALES.fetch(Recipe.scale_key(params[:scale]))
    count = Current.user.grocery_list.add_recipes([ [ @recipe, factor ] ])
    redirect_back_or_to @recipe, notice: "Added #{count} ingredients to your grocery list.", status: :see_other
  end
end
