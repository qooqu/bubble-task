class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "reset your password", to: user.email_address
  end
end
