require "csv"

# Loads staff users from the users CSV in the `data/` folder.
#
# Expected columns:
#   Email Address, Password
#
# Idempotent: existing users (matched by email) are left untouched, so
# re-running the loader never clobbers a user who has since changed their
# password.
class UserCsvLoader
  Result = Struct.new(:created, :skipped, keyword_init: true)

  def self.call(path = nil)
    new(path).call
  end

  def initialize(path = nil)
    @path = path || Rails.root.join("data", "users.csv")
  end

  def call
    raise "Users CSV not found at #{@path}" unless File.exist?(@path)

    created = skipped = 0

    CSV.foreach(@path, headers: true) do |row|
      email = row["Email Address"].to_s.strip
      password = row["Password"].to_s
      next skipped += 1 if email.blank? || password.blank?

      if User.exists?(email_address: email)
        skipped += 1
      else
        User.create!(email_address: email, password: password)
        created += 1
      end
    end

    Result.new(created: created, skipped: skipped)
  end
end
