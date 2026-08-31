# Donor Check-In System

A lightweight, high-performance event check-in and reconciliation application for WVU Libraries. Built with **Ruby on Rails**, **Hotwire (Stimulus)**, and **Tailwind CSS**, it lets staff run rapid, face-to-face donor and graduate check-ins at live events.

## Features

- **Instant client-side search** — A Stimulus controller filters the donor list as staff type, so hundreds of attendees can be located without a page reload.
- **Streamlined check-in workflow** — A detailed donor view with a quick release/waiver toggle and a structured corrections/notes field.
- **Save & Next** — Saves the update, flashes a confirmation, and returns staff to the search index for the next attendee.
- **JSONB flexible storage** — Auxiliary notes and metadata are stored cleanly in a PostgreSQL `jsonb` column.
- **One-click CSV export** — Generates and downloads a clean export of check-in statuses and notes for post-event CRM reconciliation.

## Tech Stack

- **Backend:** Ruby on Rails 8.1, PostgreSQL 16
- **Frontend:** ERB, Tailwind CSS 4, Hotwire (Stimulus.js, Turbo)
- **Testing:** RSpec, FactoryBot, Shoulda Matchers

## Project Layout

```
.
├── docker-compose.yml        # Production-style stack
├── docker-compose.dev.yml    # Development stack (with bundle cache)
├── up.sh / down.sh           # Start / stop the dev environment
├── Dockerfile / Dockerfile.dev
├── env/                      # Environment files (env, env.<environment>, env.local)
├── data/
│   └── imports/              # Source CSVs (donors.csv, users.csv)
├── scripts/                  # Container startup + setup helpers
└── wvu-moonshot/             # The Rails application
```

## Local Development Setup

This project is Docker-first. The dev container mounts the Rails app for hot reloading and caches the gem bundle.

### Prerequisites

- Docker (with the Compose plugin)
- A `data/imports/donors.csv` and `data/imports/users.csv` (or drop your dataset in)

### Start the environment

```bash
# Start the dev stack (app + Postgres + Memcached)
./up.sh

# Wait for the container to be ready, then open http://localhost:3000
```

### Environment variables

Environment files live in `env/`. Copy the local override template and fill in real values as needed:

```bash
cp env/env.local.example env/env.local
```

Values in `env/env.local` override `env/env` and `env/env.<environment>`.

### Working inside the container

```bash
docker exec -it moonshot bash

# Within the container:
cd /home/moonshot

# Create / reset the database and seed from the CSVs
bin/rails db:create db:schema:load db:seed

# Run the test suite
bundle exec rspec
```

### Stop the environment

```bash
./down.sh
```

## Data Import & Seeding

The CSV in `data/imports/` is the source of truth for donor demographics. Records are **upserted by their unique CRM ID**, so the loader is idempotent and safe to re-run (for example, when the final Foundation dataset arrives) without clobbering event data such as waiver status and notes.

```bash
bin/rails db:seed    # Load / refresh donors from donors.csv and create users
bin/rails db:setup    # Create + load schema + seed (fresh start)
```

## Running Tests

```bash
bundle exec rspec
```

## Deployment / VM Operations

The application is containerized and deployed to a VM for live testing and event-day operations via `docker-compose.yml`.

- For CSV data imports or staging resets, ensure the production database environment variables are configured correctly in `env/env.production`.
- Health checks are available at `/up`.