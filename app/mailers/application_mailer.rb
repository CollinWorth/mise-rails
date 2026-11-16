class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "Mise <noreply@example.com>")
  layout "mailer"
end
