#!/bin/bash
# remove docker volumes
docker volume prune --all --force
# remove contents of ./data/logs
rm -rf ./data/logs/*
# remove postgres data directory
rm -rf ./data/postgres
# NOTE: Do NOT remove ./data/imports - it contains the CSV seed data that should persist
# remove the moonshot/tmp directory
rm -rf ./galaxy-game-ui/tmp