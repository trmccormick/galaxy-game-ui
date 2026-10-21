# Seeds the app from the users CSV in the `data/` folder.
#
#   bin/rails db:seed          # load/refresh users from data/users.csv
#   bin/rails db:setup         # create + migrate + seed (fresh start)
#
# Idempotent: existing users (matched by email) are left untouched, so
# this can be re-run safely without overwriting user accounts.

users = UserCsvLoader.call
puts "Users CSV loaded: #{users.created} created, #{users.skipped} skipped."
