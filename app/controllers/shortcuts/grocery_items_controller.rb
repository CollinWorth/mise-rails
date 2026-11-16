# For the Siri Shortcut: adds what you said to your grocery list. It signs in with a key in an Authorization header
# ("Bearer …", made on the profile page) instead of a session.
class Shortcuts::GroceryItemsController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection
  rate_limit to: 60, within: 1.minute, with: -> { render json: { message: "Too many tries. Wait a minute." }, status: :too_many_requests }

  def create
    user = User.find_by_shortcut_token(request.authorization.to_s[/\ABearer (\S+)\z/, 1])
    return render json: { message: "That key isn't valid. Make a new one in Mise." }, status: :unauthorized unless user

    names = user.grocery_list.add_phrases(params[:text])
    return render json: { message: "I didn't catch anything to add.", added: [] }, status: :unprocessable_content if names.empty?

    render json: { message: "Added #{names.to_sentence} to your grocery list.", added: names }, status: :created
  end
end
