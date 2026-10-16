class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Reset your Bubble Task password", to: user.email_address
  end
end
