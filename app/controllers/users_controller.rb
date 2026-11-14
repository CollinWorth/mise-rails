class UsersController < ApplicationController
  allow_unauthenticated_access

  def index
    users = params[:q].present? ? User.named_like(params[:q]) : User.all
    pagy, users = pagy(:offset, users.order(:name), limit: 24)
    render Views::Users::Index.new(users:, pagy:, query: params[:q].to_s)
  end

  def show
    user = User.find(params[:id])
    pagy, recipes = pagy(:offset, user.recipes.published.newest.with_attached_image.includes(:ratings), limit: 12)
    render Views::Users::Show.new(user:, recipes:, pagy:, collections: user.collections.published.newest.to_a)
  end
end
