class LikesController < ApplicationController
  include RecipeScoped

  def create
    @recipe.likes.find_or_create_by(user: Current.user)
    redirect_back_or_to @recipe, status: :see_other
  end

  def destroy
    @recipe.likes.where(user: Current.user).destroy_all
    redirect_back_or_to @recipe, status: :see_other
  end
end
