# Turns a URL or pasted text into an unsaved recipe and shows it in the
# normal new-recipe form so it can be reviewed before saving.
class Recipes::ImportsController < ApplicationController
  def new
    render Views::Recipes::Imports::New.new
  end

  def create
    recipe = Current.user.recipes.build(RecipeImport.new(params.permit(:url, :text)).attributes)
    # Turbo only accepts a redirect or an error status in answer to a form post. The draft isn't saved yet, so it is
    # shown the way an invalid form is: re-rendered with 422.
    render Views::Recipes::New.new(recipe:), status: :unprocessable_content
  rescue RecipeImport::Failed => error
    redirect_to new_recipes_import_path, alert: error.message, status: :see_other
  end
end
