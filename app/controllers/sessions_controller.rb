# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: lambda {
    redirect_to new_session_path, alert: t("try_again")
  }

  def new; end

  def create
    if (user = User.authenticate_by(email_address: params[:email_address], password: params[:password]))
      start_new_session_for user
      if user.admin
        redirect_to admin_index_path
      else
        redirect_to user_path(user.id)
      end
    else
      redirect_to new_session_path, alert: t("try_a_different_email")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
