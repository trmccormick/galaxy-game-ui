require "rails_helper"
require "csv"
require "tmpdir"

RSpec.describe DonorCsvLoader do
  def write_csv(rows, headers)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "donors.csv")
      CSV.open(path, "w") do |csv|
        csv << headers
        rows.each { |row| csv << row }
      end
      yield path
    end
  end

  let(:headers) do
    ["CRM ID", "First Name", "Surname", "Primary Constituency",
     "Educational/College Code", "Educational Sub-Department Code", "Class Year"]
  end

  describe ".call" do
    it "creates records from a CSV" do
      write_csv([
        ["WVU-900001", "Jordan", "Rivers", "Alumni Association", "COE", "CSC", "2015"]
      ], headers) do |path|
        result = described_class.call(path)
        expect(result.created).to eq(1)
        expect(result.updated).to eq(0)

        record = GraduateRecord.find_by!(crm_id: "WVU-900001")
        expect(record.first_name).to eq("Jordan")
        expect(record.surname).to eq("Rivers")
        expect(record.college_code).to eq("COE")
        expect(record.class_year).to eq("2015")
      end
    end

    it "updates demographics on re-run without clobbering event data" do
      write_csv([
        ["WVU-900002", "Jordan", "Rivers", "Alumni Association", "COE", "CSC", "2015"]
      ], headers) do |path|
        described_class.call(path)
        record = GraduateRecord.find_by!(crm_id: "WVU-900002")
        record.update!(waiver_completed: true, notes: "Checked in.")

        # Re-run with updated demographics
        write_csv([
          ["WVU-900002", "Jordan", "Rivers-Smith", "West Virginia", "COE", "CSC", "2016"]
        ], headers) do |path2|
          result = described_class.call(path2)
          expect(result.updated).to eq(1)

          record.reload
          expect(record.surname).to eq("Rivers-Smith")
          expect(record.waiver_completed).to be(true)
          expect(record.notes).to eq("Checked in.")
        end
      end
    end

    it "skips rows without a CRM ID" do
      write_csv([
        ["", "No", "Id", "Alumni Association", "COE", "CSC", "2015"]
      ], headers) do |path|
        result = described_class.call(path)
        expect(result.skipped).to eq(1)
        expect(GraduateRecord.count).to eq(0)
      end
    end

    it "stores unrecognized columns in the jsonb data store" do
      extended_headers = headers + ["Preferred Name"]
      write_csv([
        ["WVU-900003", "Jordan", "Rivers", "Alumni Association", "COE", "CSC", "2015", "Jordy"]
      ], extended_headers) do |path|
        described_class.call(path)
        record = GraduateRecord.find_by!(crm_id: "WVU-900003")
        expect(record.data).to include("Preferred Name" => "Jordy")
      end
    end

    it "raises when the CSV file is missing" do
      expect {
        described_class.call("/nonexistent/donors.csv")
      }.to raise_error(RuntimeError, /Donor CSV not found/)
    end
  end
end
