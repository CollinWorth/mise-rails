class PasswordsController < ApplicationController
  def update
    if Current.user.authenticate(params[:current_password]) && Current.user.update(params.permit(:password))
      redirect_to profile_path, notice: "Password updated."
    else
      redirect_to profile_path, alert: "Could not update password."
    end
  end
end
