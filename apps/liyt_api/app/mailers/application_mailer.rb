class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("FROM_EMAIL", "deliveries@liyt.com")
  layout "mailer"
end
