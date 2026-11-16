class PasswordResetsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail to: user.email_address, subject: "Reset your Mise password"
  end
end
