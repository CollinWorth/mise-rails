class RatingsController < ApplicationController
  include RecipeScoped

  def update
    @recipe.rated_recipe.ratings.find_or_initialize_by(user: Current.user).update!(value: params.expect(:value))
    redirect_to @recipe, status: :see_other
  end

  def destroy
    @recipe.rated_recipe.ratings.where(user: Current.user).destroy_all
    redirect_to @recipe, status: :see_other
  end
end
