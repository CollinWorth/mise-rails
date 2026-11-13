# Puts a recipe's ingredients (at the chosen scale) on your grocery list.
class Recipes::GroceryItemsController < ApplicationController
  include RecipeScoped

  def create
    result = Current.user.grocery_list.add_recipes([ [ @recipe, Scale.pick(params[:scale]).factor ] ])
    redirect_back_or_to @recipe, notice: result.summary, status: :see_other
  end
end
