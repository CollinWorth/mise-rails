class PasswordsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :update, with: -> { redirect_to profile_path, alert: "Try again later." }

  def update
    if Current.user.authenticate(params[:current_password]) && Current.user.update(params.permit(:password))
      redirect_to profile_path, notice: "Password updated."
    else
      redirect_to profile_path, alert: "Could not update password."
    end
  end
end
