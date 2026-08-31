require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { should have_db_column(:email_address).of_type(:string) }
    it { should have_db_column(:password_digest).of_type(:string) }
  end

  describe "normalization" do
    it "downcases and strips the email address" do
      user = build(:user, email_address: "  Admin@WVU.edu ")
      expect(user.email_address).to eq("admin@wvu.edu")
    end
  end

  describe "authentication" do
    it "authenticates with the correct password" do
      user = create(:user, password: "Moonshot2026!")
      expect(User.authenticate_by(email_address: user.email_address, password: "Moonshot2026!")).to eq(user)
    end

    it "rejects an incorrect password" do
      user = create(:user)
      expect(User.authenticate_by(email_address: user.email_address, password: "wrong")).to be_nil
    end
  end

  describe "associations" do
    it { should have_many(:sessions).dependent(:destroy) }
  end
end
