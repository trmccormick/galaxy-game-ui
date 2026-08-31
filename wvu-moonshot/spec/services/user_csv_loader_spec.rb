require "rails_helper"
require "csv"
require "tmpdir"

RSpec.describe UserCsvLoader do
  def write_csv(rows)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "users.csv")
      CSV.open(path, "w") do |csv|
        csv << ["Email Address", "Password"]
        rows.each { |row| csv << row }
      end
      yield path
    end
  end

  describe ".call" do
    it "creates users from a CSV" do
      write_csv([["admin@wvu.edu", "Moonshot2026!"]]) do |path|
        result = described_class.call(path)
        expect(result.created).to eq(1)

        user = User.find_by!(email_address: "admin@wvu.edu")
        expect(User.authenticate_by(email_address: "admin@wvu.edu", password: "Moonshot2026!")).to eq(user)
      end
    end

    it "skips existing users without changing their password" do
      user = create(:user, email_address: "admin@wvu.edu", password: "OriginalPass1!")

      write_csv([["admin@wvu.edu", "NewPass123!"]]) do |path|
        result = described_class.call(path)
        expect(result.skipped).to eq(1)
        expect(User.authenticate_by(email_address: "admin@wvu.edu", password: "OriginalPass1!")).to eq(user)
      end
    end

    it "skips rows with missing email or password" do
      write_csv([
        ["", "NoEmail123!"],
        ["nope@wvu.edu", ""]
      ]) do |path|
        result = described_class.call(path)
        expect(result.skipped).to eq(2)
        expect(User.count).to eq(0)
      end
    end

    it "raises when the CSV file is missing" do
      expect {
        described_class.call("/nonexistent/users.csv")
      }.to raise_error(RuntimeError, /Users CSV not found/)
    end
  end
end
