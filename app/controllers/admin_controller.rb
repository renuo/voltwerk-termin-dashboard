# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticated?

  def index
    @index ||= get_resource_at("https://graph.microsoft.com/v1.0/me")
  end

  def new; end

  def create
    new_user = User.new(email_address: params[:email_address],
                        password_digest: BCrypt::Password.create(params[:password]),
                        handle: params[:handle],
                        date_of_birth: params[:date_of_birth],
                        job_title: params[:job_title])
    new_user.save!
    redirect_to admin_index_path
  end
end
