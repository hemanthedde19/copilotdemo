#!/usr/bin/env bash
# Usage: ./scripts/create-repo.sh [--private] [--name owner/repo] or set GH_REPOSITORY
# Creates a GitHub repo for the current project and pushes the current main branch.
set -euo pipefail

if ! command -v gh &>/dev/null; then
  echo "gh CLI not found. Install it from https://cli.github.com/"
  exit 1
fi

PRIVATE="false"
FULL_REPO=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --private)
      PRIVATE="true"
      shift
      ;;
    --name)
      FULL_REPO="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      shift
      ;;
  esac
done

# Determine repo name from current directory if not specified
if [ -z "$FULL_REPO" ]; then
  name=$(basename "$(pwd)")
  FULL_REPO="$name"
fi

VISIBILITY="--public"
if [ "$PRIVATE" = "true" ]; then
  VISIBILITY="--private"
fi

if [ "$FULL_REPO" = "$name" ]; then
  echo "Creating ${FULL_REPO} under your GitHub account (use --name owner/repo to change)."
  gh repo create "$FULL_REPO" $VISIBILITY --confirm
else
  echo "Creating $FULL_REPO (owner/repo)"
  gh repo create "$FULL_REPO" $VISIBILITY --confirm
fi

# Initialize git if needed
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  git init
  git checkout -b main
fi

git add .
if git commit -m "Initial commit"; then
  echo "Committed"
else
  echo "Nothing to commit or commit failed. Continuing..."
fi

# Push
git remote remove origin 2>/dev/null || true
if [[ "$FULL_REPO" == *"/"* ]]; then
  # full owner/repo specified
  git remote add origin "git@github.com:${FULL_REPO}.git"
else
  # use current account
  owner=$(gh api user --jq .login)
  git remote add origin "git@github.com:${owner}/${FULL_REPO}.git"
fi

git push -u origin main

# Offer to setup secrets using scripts/setup-secrets.sh
if [ -f scripts/setup-secrets.sh ]; then
  echo "You can now run scripts/setup-secrets.sh to configure repository secrets via gh CLI."
fi

echo "Repo created and pushed: $FULL_REPO"
