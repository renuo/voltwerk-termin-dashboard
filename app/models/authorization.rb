# frozen_string_literal: true

class Authorization < ApplicationRecord
  encrypts :access_token, deterministic: true
  encrypts :refresh_token, deterministic: true
end
