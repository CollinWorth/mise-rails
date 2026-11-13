# Turns a web address, pasted text or sorted lines into an unsaved recipe and shows it in the normal new-recipe form so it can be
# reviewed before saving. Text the reader isn't sure about goes through the sorting screen first (Views::Recipes::Imports::Reading).
class Recipes::ImportsController < ApplicationController
  MAX_LINES = 400
  MAX_LINE_LENGTH = 1_000

  def new
    render Views::Recipes::Imports::New.new
  end

  # Turbo only accepts a redirect or an error status in answer to a form post. Nothing is saved yet, so both the sorting screen
  # and the draft are shown the way an invalid form is: re-rendered with 422.
  def create
    import = RecipeImport.new(import_params)

    if import.from_text? && (params[:check] || !import.confident?)
      render Views::Recipes::Imports::Reading.new(lines: import.lines, unsure: !params[:check]), status: :unprocessable_content
    else
      recipe = Current.user.recipes.build(import.attributes)
      render Views::Recipes::New.new(recipe:, lines: (import.lines if import.from_text?)), status: :unprocessable_content
    end
  rescue RecipeImport::Failed => error
    redirect_to new_recipes_import_path, alert: error.message, status: :see_other
  end

  private
    def import_params
      params.permit(:url, :text).to_h.symbolize_keys.merge(lines: sorted_lines)
    end

    # The lines a cook has sorted: `lines[0][text]`, `lines[0][role]`, ... in the order they were shown.
    def sorted_lines
      raw = params[:lines]
      return [] unless raw.respond_to?(:values)

      raw.values.first(MAX_LINES).filter_map do |line|
        { text: line[:text].to_s.first(MAX_LINE_LENGTH), role: line[:role].to_s } if line.respond_to?(:permit)
      end
    end
end
