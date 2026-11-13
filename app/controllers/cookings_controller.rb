# The "I cooked this" button on a recipe: logs a cooking, and takes back the latest one (for a day) if it was a mistake.
class CookingsController < ApplicationController
  include RecipeScoped

  def create
    Current.user.cookings.create!(recipe: @recipe)
    times = Current.user.cookings.where(recipe: @recipe).count
    redirect_back_or_to @recipe, notice: "Logged! That's #{times == 1 ? 'the first time' : "time ##{times}"} you've cooked #{@recipe.name}.", status: :see_other
  end

  def destroy
    latest = Current.user.cookings.where(recipe: @recipe).newest.first
    latest.destroy if latest&.undoable?
    redirect_back_or_to @recipe, status: :see_other
  end
end
