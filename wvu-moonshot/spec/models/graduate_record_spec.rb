require "rails_helper"

RSpec.describe GraduateRecord, type: :model do
  describe "validations" do
    it { should validate_presence_of(:crm_id) }
    it { should validate_uniqueness_of(:crm_id) }
  end

  describe ".search_by_surname" do
    let!(:rivers) { create(:graduate_record, first_name: "Jordan", surname: "Rivers") }
    let!(:chase) { create(:graduate_record, first_name: "Emily", surname: "Chase") }

    it "returns all records for a blank term" do
      expect(described_class.search_by_surname("  ")).to include(rivers, chase)
    end

    it "matches surnames case-insensitively" do
      expect(described_class.search_by_surname("rivers")).to include(rivers)
    end

    it "matches partial surnames" do
      expect(described_class.search_by_surname("Riv")).to include(rivers)
    end

    it "does not match unrelated surnames" do
      expect(described_class.search_by_surname("rivers")).not_to include(chase)
    end

    it "orders results by surname then first name" do
      create(:graduate_record, first_name: "Aaron", surname: "Rivers")
      results = described_class.search_by_surname("rivers")
      expect(results.map(&:first_name)).to eq(["Aaron", "Jordan"])
    end

    it "limits results to 50" do
      55.times { |i| create(:graduate_record, surname: "Bulk", first_name: "Donor#{i}") }
      expect(described_class.search_by_surname("bulk").count).to eq(50)
    end
  end

  describe "#combined_name" do
    it "returns first name + surname" do
      record = build(:graduate_record, first_name: "Jordan", surname: "Rivers")
      expect(record.combined_name).to eq("Jordan Rivers")
    end

    it "handles nil first name" do
      record = build(:graduate_record, first_name: nil, surname: "Rivers")
      expect(record.combined_name).to eq("Rivers")
    end
  end

  describe "#display_name" do
    it "returns the combined name when present" do
      expect(build(:graduate_record).display_name).to eq("Jordan Rivers")
    end

    it "falls back to the record id when name fields are blank" do
      record = build(:graduate_record, first_name: nil, surname: nil)
      record.id = 42
      expect(record.display_name).to eq("Record #42")
    end
  end

  describe "#merge_data!" do
    it "merges attributes into the jsonb store" do
      record = build(:graduate_record, data: { "Existing" => "value" })
      record.merge_data!(NewField: "added")
      expect(record.data).to include("Existing" => "value", "NewField" => "added")
    end

    it "drops blank values" do
      record = build(:graduate_record, data: {})
      record.merge_data!(Blank: "", Present: "yes")
      expect(record.data).to eq("Present" => "yes")
    end
  end
end
