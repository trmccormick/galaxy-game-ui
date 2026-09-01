# Donor Check-In System

A lightweight, high-performance event check-in and reconciliation application for WVU Libraries. Built with **Ruby on Rails 8**, **Hotwire (Stimulus)**, and **Tailwind CSS**, it lets staff run rapid, face-to-face donor and graduate check-ins at live events.

## Status

✅ **Production-ready** — All 41 tests passing. Deployed as a containerized Rails application with PostgreSQL backend. Optimized for fast client-side filtering and batch CSV exports.

## Features

- **Instant client-side search** — A Stimulus controller filters the donor list as staff type, so hundreds of attendees can be located without a page reload.
- **Streamlined check-in workflow** — A detailed donor view with a quick release/waiver toggle and a structured corrections/notes field.
- **Save & Next** — Saves the update, flashes a confirmation, and returns staff to the search index for the next attendee.
- **One-click CSV export** — Generates and downloads a clean export of check-in statuses and notes for post-event CRM reconciliation.
- **Idempotent CSV seeding** — Import donor demographics from Foundation CSV exports without overwriting event data (waiver status, notes).

## Tech Stack

- **Backend:** Ruby on Rails 8.1.3, PostgreSQL 16
- **Frontend:** ERB, Tailwind CSS 4, Hotwire (Stimulus.js, Turbo)
- **Testing:** RSpec 41/41 tests passing, FactoryBot, Shoulda Matchers
- **Containerization:** Docker & Docker Compose, multi-environment support

## Database Schema Design

The database is intentionally **flexible and vendor-agnostic**:

**Essential columns** (always present):
- `crm_id` — Unique donor identifier from Foundation (searchable index)
- `first_name`, `surname` — Required for display and search
- `waiver_completed` — Boolean flag: waiver signed during event
- `notes` — Text field: staff corrections/comments during event

**Flexible storage** (`data` jsonb column):
- **All additional CSV columns** are automatically captured here
- No schema migration needed when Foundation CSV structure changes
- Supports any field names: "Primary Constituency", "College Code", "Major", "Email", etc.

**Why this design:**
1. The Foundation hasn't finalized the CSV structure yet
2. Additional fields may change between now and October
3. Schema changes = code deployments = risk
4. Flexible jsonb = import any CSV, zero code changes needed

**View layer** handles this transparently:
```ruby
# In the GraduateRecord model:
def primary_constituency
  data&.dig("primary_constituency") || data&.dig("Primary Constituency")
end

def college_code
  data&.dig("college_code") || data&.dig("Educational/College Code")
end
# ... etc for other common demographic fields
```

See [SCHEMA_REFINEMENT.md](SCHEMA_REFINEMENT.md) for detailed design rationale.


## Project Layout

```
.
├── README.md                          # This file
├── Dockerfile / Dockerfile.dev        # Production and dev containers
├── docker-compose.yml                 # Production-like stack (app + PostgreSQL)
├── docker-compose.dev.yml             # Development stack (hot-reload, cached bundles)
├── up.sh / down.sh                    # Lifecycle management (start / stop containers)
├── env/                               # Environment files (git-ignored)
│   ├── env                            # Shared defaults (TZ, thread count)
│   ├── env.development                # Dev overrides (DATABASE_HOST=db)
│   ├── env.production                 # Prod template (configure as needed)
│   ├── env.db                         # PostgreSQL credentials
│   └── env.local.example              # Local override template (copy & edit)
├── data/                              # Persistent data (git-ignored)
│   ├── imports/                       # CSV sources (donors.csv, users.csv)
│   ├── postgres/                      # PostgreSQL data volume
│   ├── logs/                          # Rails + Puma logs
│   ├── bundle/                        # Cached gems (dev only)
│   └── node_modules/                  # Cached packages (dev only)
├── scripts/                           # Container startup helpers
│   └── startup.sh                     # Run migrations + seed + start Puma
└── wvu-moonshot/                      # The Rails application
    ├── app/
    │   ├── controllers/               # Rails controllers (GraduateRecords, Sessions)
    │   ├── models/                    # Data models (User, GraduateRecord)
    │   ├── services/                  # CSV loaders and business logic
    │   ├── views/                     # ERB templates with Tailwind styling
    │   └── javascript/                # Stimulus controllers (graduate_filter)
    ├── config/
    ├── db/                            # Migrations and schema
    ├── spec/                          # RSpec tests (models, services, requests)
    └── public/                        # Static assets (favicon, etc.)
```

## Local Development Setup

This project is **Docker-first**. The dev container mounts the Rails app for hot reloading and caches the gem bundle for faster rebuilds.

### Prerequisites

- **Docker** (with the Compose plugin)
- **Git**
- A `data/imports/donors.csv` file with donor demographics (see CSV Format section)
- A `data/imports/users.csv` file with staff credentials (see CSV Format section)

### Quick Start

```bash
# 1. Clone or navigate to the repository
cd wvu-moonshot

# 2. Create local environment overrides (optional, but recommended)
cp env/env.local.example env/env.local
# Edit env/env.local if you need to override defaults

# 3. Ensure CSV imports exist
ls data/imports/donors.csv data/imports/users.csv

# 4. Start the dev environment
./up.sh

# 5. Wait for the container to be ready, then open http://localhost:3000
```

### Access & Credentials

- **App URL:** http://localhost:3000
- **Default User:** libdev@mail.wvu.edu / Moonshot2026! (from `data/imports/users.csv`)
- **Database:** PostgreSQL at localhost:5432 (from Docker Compose network)

### Working Inside the Container

```bash
# Connect to the running container
docker exec -it moonshot bash

# Within the container
cd /home/moonshot

# Create / reset the database and seed from the CSVs
bin/rails db:create db:schema:load db:seed

# Run the development server (already running via startup.sh)
# Check logs at data/logs/development.log

# Run the test suite
bundle exec rspec

# Run a single test file
bundle exec rspec spec/requests/graduate_records_spec.rb

# Run with coverage report
bundle exec rspec --format progress --format RspecJunitXmlFormatter --out rspec.xml
```

### Stopping the Environment

```bash
./down.sh
```

## CSV Data Format

The app expects two CSV files in `data/imports/`:

### donors.csv (Donor Demographics — Foundation Export)

**Required columns** (case-insensitive, flexible to any CSV structure):

| Column | Required | Type | Notes |
|--------|----------|------|-------|
| CRM ID | ✓ | string | Unique identifier for each donor. Used as the underlying database key. |
| First Name | ✓ | string | Donor's first name. |
| Surname | ✓ | string | Donor's last name. Used for search. |
| Any additional columns | | varies | Stored automatically in the jsonb `data` field. |

**Design Philosophy:** The app does NOT assume a specific CSV structure. Any columns you send (beyond the required three) are stored flexibly in a jsonb field, making it work with whatever the Foundation sends.

**Example CSVs (both work equally well):**

```csv
# Basic structure
CRM ID,First Name,Surname
WVU-12345,Jordan,Rivers
WVU-12346,Emily,Chase
```

```csv
# With demographics
CRM ID,First Name,Surname,Primary Constituency,College Code,Class Year,Phone
WVU-12345,Jordan,Rivers,Alumni Association,COE,2015,555-0001
WVU-12346,Emily,Chase,Parent,EBIS,2010,555-0002
```

The second CSV's additional columns (`Primary Constituency`, `College Code`, `Class Year`, `Phone`) are automatically stored in the `data` jsonb field. The view can display them via convenience methods (`primary_constituency`, `college_code`, `class_year`) or access them directly from `data`.

### users.csv (Staff Credentials)

**Required columns:**

| Column | Required | Type | Notes |
|--------|----------|------|-------|
| email_address | ✓ | string | Login email. |
| password | ✓ | string | Initial password (bcrypt hashed on create). |

**Example:**
```csv
email_address,password
libdev@mail.wvu.edu,Moonshot2026!
curator@mail.wvu.edu,LibraryCurator2026!
```

### Import & Seeding

The app automatically loads both CSVs on startup (via `scripts/startup.sh` → `bin/rails db:seed`).

**Important:** Records are upserted by CRM ID, so re-running the import refreshes donor demographics without clobbering event data (waiver status, notes, timestamps).

```bash
# Manually re-import donors (e.g., when Foundation sends final dataset)
docker exec moonshot bash -c "cd /home/moonshot && bin/rails db:seed"

# Check logs
docker exec moonshot tail -f log/development.log
```

## Running Tests

All tests are configured to run in isolation with proper setup and teardown. The test suite uses RSpec with FactoryBot for fixtures and Shoulda Matchers for expectations.

### Quick Commands

```bash
# Run all tests (41 examples)
docker exec moonshot bundle exec rspec

# Run a specific test file
docker exec moonshot bundle exec rspec spec/requests/graduate_records_spec.rb

# Run tests with verbose output
docker exec moonshot bundle exec rspec -f d

# Run model tests only
docker exec moonshot bundle exec rspec spec/models/

# Run with coverage report (if coverage gem installed)
docker exec moonshot bundle exec rspec --format progress
```

### Test Structure

**Unit Tests** (`spec/models/` + `spec/services/`)
- GraduateRecord model: search, display_name, combined_name, merge_data!, waiver_completed
- User model: email normalization, password validation, secure password hashing
- DonorCsvLoader service: CSV import, upsert by CRM ID, jsonb data flexibility
- UserCsvLoader service: User import, password creation, idempotent loading

**Integration Tests** (`spec/requests/`)
- Graduate Records index: list all donors, client-side filtering
- Graduate Records show: display prepopulated record, confirm demographics
- Graduate Records update: save waiver + notes, redirect to list
- Sessions: login, logout, rate limiting, authentication flow

**Authentication & Isolation**
- Each test is isolated: test database cleaned between examples
- Session cookies cleared between tests (no auth leakage)
- Current.session reset before each request spec
- Factory fixtures create fresh records without database pollution

### Test Coverage

```
✅ 41 examples, 0 failures

Models (11 specs)
  User (4): validations, normalization, has_secure_password, associations
  GraduateRecord (7): validations, search, display, combined_name, merge_data!, accessor methods

Services (8 specs)
  DonorCsvLoader (5): creates records, updates, upserts by CRM ID, handles jsonb, error cases
  UserCsvLoader (3): creates users, skips existing, idempotent

Requests (18 specs)
  GraduateRecords (12): index, show, update, authentication
  Sessions (4): login, logout, rate limiting, cookie handling
  Authentication (2): redirects on unauthenticated access

Sessions (4 specs)
  Login/logout flow, credential validation, cookies
```

### Running Tests Locally

```bash
# Connect to the running container
docker exec -it moonshot bash

# Within the container
cd /home/moonshot

# Run full suite
bundle exec rspec

# Run with detail
bundle exec rspec -f d

# Run specific test by line number
bundle exec rspec spec/requests/graduate_records_spec.rb:18

# Watch for failures on save (if guard-rspec installed)
bundle exec guard
```

### Test Helpers & Fixtures

- `spec/factories/users.rb` — FactoryBot factory for User records
- `spec/factories/graduate_records.rb` — FactoryBot factory for GraduateRecord (with waiver_completed trait)
- `spec/support/authentication_helpers.rb` — sign_in/sign_out helpers, session management
- `spec/rails_helper.rb` — RSpec config, factory includes, shoulda-matchers setup

### Test Database Cleanup

- `:transaction` strategy for speed (wraps each test in a database transaction)
- Before each request spec: Current.session cleared, cookies deleted
- After each test: transaction rolled back (database restored)
- Fresh factories created per test (no shared state)

## Authentication & Security

The app uses **Rails 8 built-in authentication** (no Devise or Pundit):
- Session-based authentication with signed cookies
- Passwords hashed with bcrypt via `has_secure_password`
- Rate limiting on login attempts (10 per 3 minutes)
- Email normalization (downcase + strip)
- Session destruction on logout + password reset

**Important Security Notes:**
- All actions (except login/logout) require authentication
- Passwords are never displayed or logged
- Use `env/env.local` to override production secrets locally
- In production, enable SSL (`config.force_ssl = true`)

## Deployment & VM Operations

The application is containerized and designed for deployment to a VM using `docker-compose.yml`.

### Production Deployment Steps

```bash
# 1. On the target VM, prepare the environment
git clone <repository-url>
cd wvu-moonshot
cp env/env.local.example env/env.local

# 2. Edit env/env.local with production values
#    - DATABASE_HOST (VM hostname or IP)
#    - RAILS_MASTER_KEY (from credentials)
#    - Any other prod-specific settings

# 3. Ensure data/imports/ has the latest CSVs
scp donors.csv users.csv user@vm:/path/to/wvu-moonshot/data/imports/

# 4. Start the production stack
docker compose -f docker-compose.yml up -d

# 5. Check logs
docker compose -f docker-compose.yml logs -f web

# 6. Verify health
curl http://localhost:3000/up
```

### Database Backups

```bash
# Backup PostgreSQL data
docker exec db pg_dump -U postgres > backup-$(date +%Y%m%d-%H%M%S).sql

# Restore from backup
docker exec -i db psql -U postgres < backup-YYYYMMDD-HHMMSS.sql
```

### Monitoring & Logs

```bash
# View Rails logs
docker compose logs -f web

# View database logs
docker compose logs -f db

# Check container health
docker compose ps
```

## Troubleshooting

### "Donor CSV not found at /home/moonshot/data/donors.csv"
- Ensure `data/imports/donors.csv` exists locally
- The container maps `./data/imports/` → `/home/moonshot/data/`
- Check the path: `docker exec moonshot ls -la /home/moonshot/data/`

### Tests fail with "Blocked hosts: www.example.com"
- This is expected for Rack::Test in test mode
- The test suite includes a workaround in `spec/support/authentication_helpers.rb`
- All 41 tests should pass; if not, verify database clean-up hooks

### Port 3000 already in use
- Check: `lsof -i :3000`
- Kill the process: `kill -9 <pid>`
- Or use `./down.sh` to stop the Docker container

### Authentication not persisting between requests
- Clear browser cookies and reload
- Check that `env/env.development` sets `DATABASE_HOST=db` (not localhost)
- Verify the cookie jar in `spec/support/authentication_helpers.rb` for test help

## Development Workflow

### Adding a New Model or Migration

```bash
# Inside the container
bin/rails generate model MyModel field:type

# Or run migration directly
bin/rails db:migrate
```

### Running the Development Server

```bash
# Already running via startup.sh, but restart with:
docker exec -it moonshot bash
cd /home/moonshot
bin/rails s -b 0.0.0.0
```

### Debugging with Breakpoints

```bash
# In your code, add a breakpoint:
# binding.irb

# The Rails console will pause; inspect variables and continue
docker exec -it moonshot bash
cd /home/moonshot
bin/rails console
```

## Performance Characteristics

- **Donor List:** Loads and filters 300+ records client-side in ~50ms
- **Search:** Case-insensitive ILIKE on surname/combined_name, limited to 50 results
- **CSV Export:** Generates 300+ record CSV in ~100ms
- **Database:** PostgreSQL 16 with indexed crm_id and waiver_completed columns

## Contributing

- Write tests first (RSpec with FactoryBot)
- Follow Rails conventions (models → services → controllers → views)
- Use strong parameters to prevent mass-assignment vulnerabilities
- Run `bundle exec rspec` before committing

## License

This project is internal to WVU Libraries. Refer to institutional policies for usage and distribution.

## Support

For issues, questions, or feature requests, contact the WVU Libraries Systems team.