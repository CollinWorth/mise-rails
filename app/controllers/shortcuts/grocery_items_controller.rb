# For the Siri Shortcut: adds what you said to your grocery list.
class Shortcuts::GroceryItemsController < ApplicationController
  include ShortcutAuthenticated

  def create
    names = @user.grocery_list.add_phrases(params[:text])
    return render json: { message: "I didn't catch anything to add.", added: [] }, status: :unprocessable_content if names.empty?

    render json: { message: "Added #{names.to_sentence} to your grocery list.", added: names }, status: :created
  end
end
