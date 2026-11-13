class FollowsController < ApplicationController
  before_action :set_user

  def create
    Current.user.follows.find_or_create_by(followed: @user)
    redirect_back_or_to @user, status: :see_other
  end

  def destroy
    Current.user.follows.where(followed: @user).destroy_all
    redirect_back_or_to @user, status: :see_other
  end

  private
    def set_user = @user = User.find(params[:user_id])
end
