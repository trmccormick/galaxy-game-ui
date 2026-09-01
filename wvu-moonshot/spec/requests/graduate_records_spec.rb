require "rails_helper"

RSpec.describe "GraduateRecords", type: :request do
  let(:user) { create(:user) }
  let!(:rivers) { create(:graduate_record, first_name: "Jordan", surname: "Rivers") }
  let!(:chase) { create(:graduate_record, first_name: "Emily", surname: "Chase") }

  describe "authentication" do
    it "redirects unauthenticated visitors to sign in" do
      get graduate_records_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET /graduate_records (authenticated)" do
    before { sign_in(user) }

    it "renders the check-in list with all donors" do
      get graduate_records_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Jordan Rivers")
      expect(response.body).to include("Emily Chase")
    end

    it "lists all donors regardless of the query param (filtering is client-side)" do
      get graduate_records_path, params: { q: "rivers" }
      expect(response.body).to include("Jordan Rivers")
      expect(response.body).to include("Emily Chase")
    end
  end

  describe "GET /graduate_records/:id (authenticated)" do
    before { sign_in(user) }

    it "shows the donor's demographics" do
      get graduate_record_path(rivers)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Jordan Rivers")
      expect(response.body).to include("Alumni Association")
      expect(response.body).to include("2015")
    end
  end

  describe "GET /graduate_records/:id (unauthenticated)" do
    it "redirects to sign in" do
      get graduate_record_path(rivers)
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "PATCH /graduate_records/:id (authenticated)" do
    before { sign_in(user) }

    it "saves waiver status and notes and redirects back to the list" do
      patch graduate_record_path(rivers), params: {
        graduate_record: { waiver_completed: "1", notes: "Preferred name is Jordy." }
      }
      expect(response).to redirect_to(graduate_records_path)

      rivers.reload
      expect(rivers.waiver_completed).to be(true)
      expect(rivers.notes).to eq("Preferred name is Jordy.")
    end

    it "does not allow mass-assignment of protected fields" do
      patch graduate_record_path(rivers), params: {
        graduate_record: { waiver_completed: "1", crm_id: "HACKED", surname: "Evil" }
      }
      rivers.reload
      expect(rivers.surname).to eq("Rivers")
      expect(rivers.crm_id).to start_with("WVU-TEST")
    end
  end

  describe "PATCH /graduate_records/:id (unauthenticated)" do
    it "redirects to sign in" do
      patch graduate_record_path(rivers), params: { graduate_record: { waiver_completed: "1" } }
      expect(response).to redirect_to(new_session_path)
      expect(rivers.reload.waiver_completed).to be(false)
    end
  end
end
