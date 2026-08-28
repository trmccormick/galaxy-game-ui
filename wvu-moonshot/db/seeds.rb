# Seeds the app from the donor CSV in the `data/` folder and creates test users.
#
#   bin/rails db:seed          # load/refresh donors from data/donors.csv
#   bin/rails db:setup         # create + migrate + seed (fresh start)
#
# Idempotent: donors are upserted by their unique CRM identifier, so this can
# be re-run safely (e.g. when the final Foundation dataset arrives). Event data
# (waiver status, corrections/notes) is preserved on re-runs.

# Create test user for development/staging login
unless User.exists?(email_address: "admin@wvu.edu")
  User.create!(
    email_address: "admin@wvu.edu",
    password: "Moonshot2026!",
    password_confirmation: "Moonshot2026!"
  )
  puts "Created test user: admin@wvu.edu / Moonshot2026!"
end

result = DonorCsvLoader.call
puts "Donor CSV loaded: #{result.created} created, #{result.updated} updated, #{result.skipped} skipped."
