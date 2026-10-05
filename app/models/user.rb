class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  validates :handle , presence: true
  validates :date_of_birth, presence: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
