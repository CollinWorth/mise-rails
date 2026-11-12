# Turns a URL or pasted text into an unsaved recipe and shows it in the
# normal new-recipe form so it can be reviewed before saving.
class Recipes::ImportsController < ApplicationController
  def new
    render Views::Recipes::Imports::New.new
  end

  def create
    recipe = Current.user.recipes.build(RecipeImport.new(params.permit(:url, :text)).attributes)
    render Views::Recipes::New.new(recipe:)
  rescue RecipeImport::Failed => error
    redirect_to new_recipes_import_path, alert: error.message
  end
end
