class PasswordResetsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 5, within: 10.minutes, only: :create, with: -> { redirect_to new_password_reset_path, alert: "Try again later." }
  before_action :set_user, only: %i[edit update]

  def new
    render Views::PasswordResets::New.new
  end

  # Same answer whether or not the email has an account, so this can't be used to find out who has one.
  def create
    if (user = User.find_by(email_address: params[:email_address]))
      PasswordResetsMailer.reset(user).deliver_later
    end
    redirect_to new_session_path, notice: "If that email has an account, a link to choose a new password is on its way.", status: :see_other
  end

  def edit
    render Views::PasswordResets::Edit.new(token: params[:token])
  end

  def update
    if @user.update(params.permit(:password))
      @user.sessions.destroy_all # anyone who had the old password is signed out
      redirect_to new_session_path, notice: "Password updated. Sign in with it.", status: :see_other
    else
      render Views::PasswordResets::Edit.new(token: params[:token], errors: @user.errors.full_messages), status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_reset_path, alert: "That link has expired. Ask for a new one.", status: :see_other
    end
end
