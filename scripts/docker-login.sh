#!/usr/bin/env bash
# Safe Docker login using environment variable DOCKERHUB_TOKEN
# Usage: export DOCKERHUB_TOKEN="<token>" && ./scripts/docker-login.sh

set -euo pipefail

if [ -z "${DOCKERHUB_USERNAME:-}" ]; then
  echo "Please set DOCKERHUB_USERNAME environment variable (e.g., export DOCKERHUB_USERNAME=hemanthedde19)"
  exit 1
fi

if [ -z "${DOCKERHUB_TOKEN:-}" ]; then
  echo "Please set DOCKERHUB_TOKEN environment variable (e.g., export DOCKERHUB_TOKEN=...)"
  exit 1
fi

echo "Logging into Docker Hub as $DOCKERHUB_USERNAME"
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

echo "Logged into Docker Hub successfully."
