require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user, password: "Moonshot2026!") }

  describe "GET /session" do
    it "renders the sign-in form" do
      get new_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    it "signs in with valid credentials" do
      post session_path, params: {
        email_address: user.email_address,
        password: "Moonshot2026!"
      }
      expect(response).to redirect_to(root_path)
      expect(cookies[:session_id]).to be_present
    end

    it "rejects invalid credentials" do
      post session_path, params: {
        email_address: user.email_address,
        password: "wrong"
      }
      expect(response).to redirect_to(new_session_path)
      # The session cookie was set to nil in the before hook, so it stays blank.
      expect(cookies[:session_id]).to be_blank
    end
  end

  describe "DELETE /session" do
    it "terminates the session" do
      sign_in(user)
      expect(cookies[:session_id]).to be_present

      delete session_path
      expect(response).to redirect_to(new_session_path)
      # The session cookie is persistent, so signing out clears it to a blank
      # value rather than removing the key entirely.
      expect(cookies[:session_id]).to be_blank
    end
  end
end
