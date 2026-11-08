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

# Clear asset manifest to force recompile
rm -f public/assets/.manifest.json
rm -f public/packs/manifest.json

# Compile Tailwind CSS (required for compiled utilities)
echo "Compiling Tailwind CSS..."
bin/rails tailwindcss:build 2>&1

# Start Rails server
echo "Starting Rails server..."
bin/rails s -p 3000 -b '0.0.0.0'
