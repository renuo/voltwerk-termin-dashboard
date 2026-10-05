class AdminController < ApplicationController
  before_action :authenticated?

  def index
    @ms_response ||= get_resource_at("https://graph.microsoft.com/v1.0/me")
  end
  def new
    puts "params: ---------------------------------"
    puts params.except(:email_address)
    puts "end =============="
  end
end
