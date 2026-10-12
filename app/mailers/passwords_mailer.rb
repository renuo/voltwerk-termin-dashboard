# frozen_string_literal: true

class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: t("pwd_reset"), to: user.email_address
  end
end
