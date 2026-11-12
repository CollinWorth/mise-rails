class Users::FollowingController < ApplicationController
  allow_unauthenticated_access

  def index
    user = User.find(params[:user_id])
    pagy, users = pagy(:offset, user.following.order(:name), limit: 24)
    render Views::Users::Connections::Index.new(user:, users:, pagy:, title: "#{user.name} follows")
  end
end
