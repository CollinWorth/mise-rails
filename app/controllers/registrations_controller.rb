class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    render Views::Registrations::New.new(user: User.new)
  end

  def create
    user = User.new(params.expect(user: %i[name email_address password]))
    if user.save
      start_new_session_for user
      redirect_to recipes_path
    else
      render Views::Registrations::New.new(user:), status: :unprocessable_content
    end
  end
end
