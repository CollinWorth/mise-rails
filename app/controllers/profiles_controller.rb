class ProfilesController < ApplicationController
  def show
    render Views::Profiles::Show.new(user: Current.user)
  end

  def update
    if Current.user.update(params.expect(user: %i[name email_address palette]))
      redirect_to profile_path, notice: (params[:user].keys == %w[palette] ? "Palette changed." : "Profile updated.")
    else
      render Views::Profiles::Show.new(user: Current.user), status: :unprocessable_content
    end
  end

  def destroy
    if Current.user.authenticate(params[:password])
      Current.user.destroy
      terminate_session
      redirect_to new_registration_path, status: :see_other
    else
      redirect_to profile_path, alert: "Incorrect password.", status: :see_other
    end
  end
end
