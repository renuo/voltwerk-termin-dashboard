# frozen_string_literal: true

class RealDataController < ApplicationController
  def index
    tokens = exchange_code_for_tokens(params[:code])

    puts "@@@@@@@@@@@@@@@@"
    puts tokens

    save_tokens(tokens)

    redirect_to admin_index_path
  end

  def new
    redirect_to microsoft_authorize_url, allow_other_host: true
  end

  private

  def microsoft_authorize_url
    tenant = "TENANT_ID"

    params = {
      client_id: "CLIENT_ID",
      response_type: "code",
      redirect_uri: ms_authenticate_index_url,
      response_mode: "query",
      scope: "User.Read Calendar.Read"
    }

    "https://login.microsoftonline.com/#{tenant}/oauth2/v2.0/authorize?#{URI.encode_www_form(params)}"
  end

  def exchange_code_for_tokens(code)
    tenant = "TENANT_ID"

    response = get_access_token(tenant, code)

    JSON.parse(response.body)
  end

  def get_access_token(tenant, code)
    connection = microsoft_url

    connection.post(
      "/#{tenant}/oauth2/v2.0/token"
    ) do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"

      req.body = URI.encode_www_form(
        client_id: "CLIENT_ID",
        client_secret: "CLIENT_SECRET",
        code: code,
        grant_type: "authorization_code",
        redirect_uri: ms_authenticate_index_url,
        scope: "User.Read Calendar.Read"
      )
    end
  end

  def microsoft_url
    Faraday.new(
      url: "https://login.microsoftonline.com"
    )
  end

  def save_tokens(tokens)
    Authorization.first_or_initialize.update!(
      access_token: tokens.fetch("access_token"),
      refresh_token: nil,
      expiry: Time.current + tokens.fetch("expires_in").seconds,
      scope: tokens["scope"]
    )
  end
end
