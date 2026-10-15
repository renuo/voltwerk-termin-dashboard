# frozen_string_literal: true

require "rails_helper"


RSpec.describe MsAuthenticateController, type: :request do
  let(:authentication) { described_class.new }

  context "with authentication" do

    let(:user) do
      User.create!(
        email_address: "admin@example.com",
        password_digest: BCrypt::Password.create("password"),
        handle: "ae",
        admin: 1,
        date_of_birth: "10-10-2000"
      )
    end

    before do
      post session_path, params: {
        email_address: user.email_address,
        password: "password"
      }
    end

    it "redirects to code url" do
      get new_ms_authenticate_path
      expect(response).to have_http_status(:redirect)
    end

    it "generates the correct url" do
      tenant = Rails.application.credentials.dig(:microslop, :tenant)

      params = {
        client_id: Rails.application.credentials.dig(:microslop, :client_id),
        response_type: "code",
        redirect_uri: "http://localhost:3000/ms_authenticate",
        response_mode: "query",
        scope: "User.Read"
      }

      check_url = authentication.send(:microsoft_authorize_url)
      expect(check_url).to eq(
        "https://login.microsoftonline.com/#{tenant}/oauth2/v2.0/authorize?#{URI.encode_www_form(params)}"
      )
    end
  end
end
