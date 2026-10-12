# frozen_string_literal: true

class TestController < ApplicationController
  before_action :authenticated?
  before_action :refresh_token_expired?, only: :index
  def index
    url = "https://graph.microsoft.com/v1.0/me"

    conn = Faraday.new url do |builder|
      builder.request :authorization, "Bearer", -> { Authorization.first!.access_token }
    end

    Rails.logger.debug conn.get("").body

    if Current.user.admin
      redirect_to admin_index_path
    else
      redirect_to dashboard_index_path
    end
  end

  private

  def validate_response(response)
    subject = JSON.parse(response.body)["subject"]

    return "error - forgot colon" unless (handles = /(^.*(?=:))/.match?(subject))

    return "error - forgot or incorrect use of +" unless /[^ +]/.match?(handles)

    "error" unless /(?<=: ).*$/.match?(subject)
  end

  def correct_handle_concatination(handles); end
end
