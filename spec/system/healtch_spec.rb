# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health check" do
  it "checks if the app is ok and connected to a database" do
    visit "/up"
    expect(page).to have_http_status(:ok)
  end
end
