# The front door for people who aren't signed in; cooks go straight to their recipes.
class LandingController < ApplicationController
  allow_unauthenticated_access

  def show
    return redirect_to recipes_path if authenticated?

    render Views::Landing::Show.new(recipes: Recipe.published.joins(:image_attachment).with_attached_image.includes(:user).newest.limit(14).to_a)
  end
end
