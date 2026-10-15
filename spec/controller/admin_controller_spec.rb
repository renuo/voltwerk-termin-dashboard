# frozen_string_literal: true

require "rails_helper"


RSpec.describe AdminController, type: :request do
  context "when unauthenticated" do
    it "get admin" do
      get admin_index_path

      expect(response).to have_http_status(:redirect)
    end
  end

  context "when authenticated" do
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

      Authorization.create!(
        access_token: "asdf",
        expiry: 100.minutes.from_now,
        refresh_token: "helllo",
        scope: "User.Read profile openid email"
      )
    end

    it "allows to access admin" do
      get admin_index_path
      expect(response).to have_http_status(:ok)
    end

    it "redirects from new to create" do
      get new_admin_path
      expect(response).to have_http_status(:ok)
    end

    it "allow to create new users" do
      post admin_index_path, params: {
        email_address: "user@example.com",
        password_digest: BCrypt::Password.create("unsafe_password"),
        job_title: "job",
        handle: "ue",
        admin: 0,
        date_of_birth: "10-11-2000"
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(admin_index_path)
    end
  end
end

