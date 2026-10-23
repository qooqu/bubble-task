class ApplicationMailer < ActionMailer::Base
  default from: "Bubble Task <no-reply@bubbletask.example.com>" # TODO: an address on the app's domain
  layout "mailer"
end
