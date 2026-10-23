class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { player: 'player', admin: 'admin' }, default: :player, prefix: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
