require "rails_helper"

RSpec.describe "GraduateRecords", type: :request do
  let(:user) { create(:user) }
  let(:rivers) { create(:graduate_record, first_name: "Jordan", surname: "Rivers") }
  let!(:chase) { create(:graduate_record, first_name: "Emily", surname: "Chase") }

  describe "authentication" do
    it "redirects unauthenticated visitors to sign in" do
      get graduate_records_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "GET /graduate_records (search)" do
    before { sign_in(user) }

    it "renders the search form without a query" do
      get graduate_records_path
      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Jordan Rivers")
    end

    it "returns matching donors for a surname query" do
      get graduate_records_path, params: { q: "rivers" }
      expect(response.body).to include("Jordan Rivers")
      expect(response.body).not_to include("Emily Chase")
    end

    it "is case-insensitive" do
      get graduate_records_path, params: { q: "RIV" }
      expect(response.body).to include("Jordan Rivers")
    end
  end

  describe "GET /graduate_records/:id (prepopulated record)" do
    before { sign_in(user) }

    it "shows the donor's demographics" do
      get graduate_record_path(rivers)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Jordan Rivers")
      expect(response.body).to include("Alumni Association")
      expect(response.body).to include("2015")
    end

    it "redirects unauthenticated visitors" do
      get graduate_record_path(rivers)
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "PATCH /graduate_records/:id (check-in save)" do
    before { sign_in(user) }

    it "saves waiver status and notes" do
      patch graduate_record_path(rivers), params: {
        graduate_record: { waiver_completed: "1", notes: "Preferred name is Jordy." }
      }
      expect(response).to redirect_to(graduate_record_path(rivers))

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

    it "redirects unauthenticated visitors" do
      patch graduate_record_path(rivers), params: { graduate_record: { waiver_completed: "1" } }
      expect(response).to redirect_to(new_session_path)
      expect(rivers.reload.waiver_completed).to be(false)
    end
  end
end
