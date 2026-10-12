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

  def refresh_token_expired?
    if Authorization.first!.expiry < 5.minutes.from_now.to_i
      refresh!(Authorization.first)
    end
  end

  def refresh!(token)
    tenant = Rails.application.credentials.dig(:microslop, :tenant)

    response = get_refresh_token(tenant, token)

    data = JSON.parse(response.body)

    token.update!(
      access_token: data.fetch("access_token"),
      refresh_token: data["refresh_token"] || token.refresh_token,
      expiry: Time.current + data.fetch("expires_in").seconds,
      scope: data["scope"] || token.scope
    )
  end

  def get_refresh_token(tenant, token)
    client_id = Rails.application.credentials.dig(:microslop, :client_id)
    client_secret = Rails.application.credentials.dig(:microslop, :client_secret)

    connection = Faraday.new(
      url: "https://login.microsoftonline.com"
    )

    connection.post(
      "/#{tenant}/oauth2/v2.0/token"
    ) do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"

      req.body = URI.encode_www_form(
        client_id: client_id,
        client_secret: client_secret,
        refresh_token: token.refresh_token,
        grant_type: "refresh_token",
        scope: "offline_access User.Read"
      )
    end
  end

  def validate_response(response)
    subject = JSON.parse(response.body)["subject"]

    return "error - forgot colon" unless (handles = /(^.*(?=:))/.match?(subject))

    return "error - forgot or incorrect use of +" unless /[^ +]/.match?(handles)

    "error" unless /(?<=: ).*$/.match?(subject)
  end

  def correct_handle_concatination(handles); end
end
