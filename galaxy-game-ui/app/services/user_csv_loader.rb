require "csv"

# Loads staff users from the users CSV in the `data/` folder.
#
# Expected columns:
#   Email Address, Password, Role
#
# Idempotent: existing users (matched by email) are left untouched, so
# re-running the loader never clobbers a user who has since changed their
# password or role.
class UserCsvLoader
  Result = Struct.new(:created, :skipped, :updated, keyword_init: true)

  ROLES = %w[player admin].freeze

  def self.call(path = nil)
    new(path).call
  end

  def initialize(path = nil)
    @path = path || Rails.root.join("data", "users.csv")
  end

  def call
    raise "Users CSV not found at #{@path}" unless File.exist?(@path)

    created = skipped = updated = 0

    CSV.foreach(@path, headers: true) do |row|
      email = row["Email Address"].to_s.strip
      password = row["Password"].to_s
      role  = row["Role"].to_s.strip.downcase.presence || "player"

      next skipped += 1 if email.blank? || password.blank?
      next skipped += 1 unless ROLES.include?(role)

      if User.exists?(email_address: email)
        user = User.find_by(email_address: email)
        if user.role != role
          user.update!(role: role)
          updated += 1
        end
        skipped += 1
      else
        User.create!(email_address: email, password: password, role: role)
        created += 1
      end
    end

    Result.new(created: created, skipped: skipped, updated: updated)
  end
end
