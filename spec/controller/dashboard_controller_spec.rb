# frozen_string_literal: true

require "rails_helper"


RSpec.describe DashboardController, type: :request do
  context "when unauthenticated" do
    it "get dashboard" do
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
    end

    it "get dashboard" do
      get dashboard_index_path
      expect(response).to have_http_status(:ok)
    end
  end
end
