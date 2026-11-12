# For controllers nested under a recipe: only recipes the current user may see.
module RecipeScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_recipe
  end

  private
    def set_recipe
      @recipe = Recipe.visible_to(Current.user).find(params[:recipe_id])
    end
end
