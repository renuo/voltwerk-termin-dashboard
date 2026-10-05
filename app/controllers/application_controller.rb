# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def get_resource_at(url)
    # url = "https://graph.microsoft.com/v1.0/me"

    if Authorization.first!.expiry < 5.minutes.from_now.to_i
      puts "######################## refreshing ############################################ refreshing ######################"
      refresh!(Authorization.first)
    end

    access_token = Authorization.first!.access_token

    conn = Faraday.new url do |builder|
      builder.request :authorization, "Bearer", -> { access_token }
    end

    puts "@@@@@@@@@@"
    puts "url: #{url}\n"
    puts conn.get("").body

    conn.get("").body
  end

  def refresh!(token)
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
        refresh_token: token.refresh_token,
        grant_type: "refresh_token",
        scope: "offline_access User.Read"
      )
    end

    data = JSON.parse(response.body)

    token.update!(
      access_token: data.fetch("access_token"),
      refresh_token: data["refresh_token"] || token.refresh_token,
      expiry: Time.current + data.fetch("expires_in").seconds,
      scope: data["scope"] || token.scope
    )
  end

  def validate_response(response)
    subject = JSON.parse(response.body)["subject"]

    return "error - forgot colon" unless (handles = /(^.*(?=:))/.match?(subject))

    return "error - forgot or incorrect use of +" unless /[^ +]/.match?(handles)

    "error" unless /(?<=: ).*$/.match?(subject)
  end
end
