class CopiesController < ApplicationController
  include RecipeScoped

  def create
    copy = @recipe.copy_for(Current.user)
    copy.save!
    redirect_to copy, notice: "Saved to your recipes.", status: :see_other
  end
end
