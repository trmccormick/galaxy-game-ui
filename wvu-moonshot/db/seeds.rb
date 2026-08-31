# Seeds the app from the donor CSV in the `data/` folder and creates test users.
#
#   bin/rails db:seed          # load/refresh donors from data/donors.csv
#   bin/rails db:setup         # create + migrate + seed (fresh start)
#
# Idempotent: donors are upserted by their unique CRM identifier, so this can
# be re-run safely (e.g. when the final Foundation dataset arrives). Event data
# (waiver status, corrections/notes) is preserved on re-runs.

users = UserCsvLoader.call
puts "Users CSV loaded: #{users.created} created, #{users.skipped} skipped."

result = DonorCsvLoader.call
puts "Donor CSV loaded: #{result.created} created, #{result.updated} updated, #{result.skipped} skipped."
