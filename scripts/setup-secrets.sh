#!/usr/bin/env bash
# Usage:
#   DOCKERHUB_USERNAME=hemanthedde19 DOCKERHUB_TOKEN=... GHCR_TOKEN=... SSH_HOST=... ./scripts/setup-secrets.sh
# This script uses the `gh` CLI to set repository secrets.
set -euo pipefail

if ! command -v gh &>/dev/null; then
  echo "gh CLI not found. Install it from https://cli.github.com/"
  exit 1
fi

REPO="${REPO:-$(basename "$(pwd)")}" # default repo name to current folder

# Allow overriding the full repo name (owner/repo)
if [ -n "${GH_REPOSITORY:-}" ]; then
  FULL_REPO="$GH_REPOSITORY"
else
  FULL_REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")"
  if [ -z "$FULL_REPO" ]; then
    echo "Not in a git repo or gh cannot determine repo. Pass GH_REPOSITORY=owner/repo or run this from the repo checkout." >&2
    exit 1
  fi
fi

set_secret_if_present() {
  secret_name="$1"
  secret_value="${!1:-}"
  if [ -n "$secret_value" ]; then
    echo "Setting secret $secret_name in $FULL_REPO"
    echo -n "$secret_value" | gh secret set "$secret_name" --repo "$FULL_REPO" --body-file -
  fi
}

set_secret_if_present DOCKERHUB_USERNAME
set_secret_if_present DOCKERHUB_TOKEN
set_secret_if_present DOCKERHUB_REPOSITORY
set_secret_if_present GHCR_TOKEN
set_secret_if_present SSH_HOST
set_secret_if_present SSH_USER
set_secret_if_present SSH_PRIVATE_KEY
set_secret_if_present DOCKER_IMAGE

echo "Secrets setup complete for $FULL_REPO"
