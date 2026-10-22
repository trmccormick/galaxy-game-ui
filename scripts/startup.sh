#!/bin/bash
set -e

# install yarn packages
yarn install --check-files 2>/dev/null || true

# set terminal 
export TERM=vt100

# start cron and update whenever 
service cron start 2>/dev/null || true
whenever --update-crontab 2>/dev/null || true

# remove PID
rm -f /home/galaxy_game/tmp/pids/server.pid

# Build Tailwind CSS explicitly
echo "Building Tailwind CSS..."
cd /home/galaxy_game
bundle exec tailwindcss -c config/tailwind.config.js -i app/assets/stylesheets/application.css -o public/assets/application-tailwind-compiled.css

# Clear asset manifest to force recompile
rm -f public/assets/.manifest.json
rm -f public/packs/manifest.json

# Start Rails server
echo "Starting Rails server..."
bin/rails s -p 3000 -b '0.0.0.0'
