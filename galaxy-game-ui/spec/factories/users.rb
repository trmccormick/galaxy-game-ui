FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@wvu.edu" }
    password { "galaxy_game2026!" }
    # has_secure_password validates that the confirmation matches the password,
    # so mirror it. This keeps the factory valid even when a spec overrides
    # `password`.
    before(:create) { |user| user.password_confirmation = user.password }
  end
end
