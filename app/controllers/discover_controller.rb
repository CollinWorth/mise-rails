class DiscoverController < ApplicationController
  allow_unauthenticated_access

  def show
    recipes = params[:tab] == "feed" && authenticated? ? Recipe.where(user: Current.user.following) : Recipe.where.not(user: Current.user)
    pagy, recipes = pagy(:offset, recipes.published.search(params[:q]).with_attached_image.includes(:user, :ratings).newest, limit: 12)
    render Views::Discover::Show.new(recipes:, pagy:, tab: params[:tab].to_s, query: params[:q].to_s)
  end
end
