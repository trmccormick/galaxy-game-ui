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
      expect(cookies[:session_id]).to be_nil
    end
  end

  describe "DELETE /session" do
    it "terminates the session" do
      sign_in(user)
      delete session_path
      expect(response).to redirect_to(new_session_path)
      expect(cookies[:session_id]).to be_nil
    end
  end
end
