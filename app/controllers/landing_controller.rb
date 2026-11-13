# The front door for people who aren't signed in; cooks go straight to their recipes.
class LandingController < ApplicationController
  allow_unauthenticated_access
  before_action -> { redirect_to recipes_path if authenticated? }

  # The fridge door.
  def show
    render Views::Landing::Show.new(recipes: published.limit(14).to_a, dinners: Recipe.published.newest.limit(10).pluck(:name).uniq)
  end

  # The previous, longer landing page, kept in case it is wanted again.
  def classic
    render Views::Landing::Classic.new(recipes: published.limit(14).to_a)
  end

  private
    def published = Recipe.published.joins(:image_attachment).with_attached_image.includes(:user).newest
end
