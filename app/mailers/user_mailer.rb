class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("account.activate.subject")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("account.activate.forgot_password")
  end
end
