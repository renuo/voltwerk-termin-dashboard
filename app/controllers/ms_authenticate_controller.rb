# frozen_string_literal: true

class MsAuthenticateController < ApplicationController
  def index
    tokens = exchange_code_for_tokens(params[:code])

    save_tokens(tokens)

    redirect_to admin_index_path
  end

  def new
    redirect_to microsoft_authorize_url, allow_other_host: true
  end

  private

  def microsoft_authorize_url
    tenant = Rails.application.credentials.dig(:microslop, :tenant)

    params = {
      client_id: Rails.application.credentials.dig(:microslop, :client_id),
      response_type: "code",
      redirect_uri: ms_authenticate_index_url,
      response_mode: "query",
      scope: "User.Read"
    }

    "https://login.microsoftonline.com/#{tenant}/oauth2/v2.0/authorize?#{URI.encode_www_form(params)}"
  end

  def exchange_code_for_tokens(code)
    tenant = Rails.application.credentials.dig(:microslop, :tenant)
    client_id = Rails.application.credentials.dig(:microslop, :client_id)
    client_secret = Rails.application.credentials.dig(:microslop, :client_secret)

    connection = Faraday.new(
      url: "https://login.microsoftonline.com"
    )

    response = connection.post(
      "/#{tenant}/oauth2/v2.0/token"
    ) do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"

      req.body = URI.encode_www_form(
        client_id: client_id,
        client_secret: client_secret,
        code: code,
        grant_type: "authorization_code",
        redirect_uri: ms_authenticate_index_url,
        scope: "offline_access User.Read"
      )
    end

    JSON.parse(response.body)
  end

  def save_tokens(tokens)
    Authorization.first_or_initialize.update!(
      access_token: tokens.fetch("access_token"),
      refresh_token: tokens.fetch("refresh_token"),
      expiry: Time.current + tokens.fetch("expires_in").seconds,
      scope: tokens["scope"]
    )
  end
end
