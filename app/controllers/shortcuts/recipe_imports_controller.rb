# For the share-sheet Shortcut: saves the recipe on a shared web page as a private recipe of yours, and says where it is.
class Shortcuts::RecipeImportsController < ApplicationController
  include ShortcutAuthenticated
  rate_limit to: 20, within: 1.minute, only: :create, name: "imports", with: -> { render json: { message: "Too many imports. Wait a minute." }, status: :too_many_requests }

  def create
    url = shared_address
    return render json: { message: "I couldn't find a web address in what was shared." }, status: :unprocessable_content unless url

    if (existing = @user.recipes.find_by(source_url: url))
      return render json: reply("You already have “#{existing.name}” saved.", existing), status: :ok
    end

    recipe = @user.recipes.build(RecipeImport.new(url:).attributes.merge(public: false))
    if recipe.save
      render json: reply("Saved “#{recipe.name}” to your recipes.", recipe), status: :created
    else
      render json: { message: "I couldn't save that recipe: #{recipe.errors.full_messages.to_sentence}." }, status: :unprocessable_content
    end
  rescue RecipeImport::Failed => error
    render json: { message: error.message }, status: :unprocessable_content
  end

  private
    # The share sheet can send a title with the address ("Great soup https://…"), so take the first web address in it.
    def shared_address = params[:url].to_s[%r{https?://\S+}]

    def reply(message, recipe) = { message:, name: recipe.name, url: recipe_url(recipe) }
end
