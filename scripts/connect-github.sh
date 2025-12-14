#!/usr/bin/env bash
# Connect local repo with GitHub using gh CLI, create repo if needed, push, and optionally set secrets.
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required. Install from https://cli.github.com/ and authenticate with 'gh auth login'"
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repo. Initializing..."
  git init
  git checkout -b main || git checkout main || true
fi

# Determine repo: allow passing owner/repo via arg or env GH_REPOSITORY
FULL_REPO="${1:-${GH_REPOSITORY:-}}"
if [ -z "$FULL_REPO" ]; then
  # try to infer owner/repo from existing git remote
  if git remote get-url origin >/dev/null 2>&1; then
    REMOTE_URL=$(git remote get-url origin)
    # convert ssh or https remote to owner/repo
    if [[ "$REMOTE_URL" =~ github.com(:|/)([^/]+/[^/.]+) ]]; then
      FULL_REPO="${BASH_REMATCH[2]}"
    fi
  fi
fi

if [ -z "$FULL_REPO" ]; then
  echo "No repository specified. Run: ./scripts/create-repo.sh --name owner/repo or supply a full repo owner/repo as the first arg"
  exit 1
fi

echo "Ensuring repo exists: $FULL_REPO"
if ! gh repo view "$FULL_REPO" >/dev/null 2>&1; then
  echo "Repository doesn't exist remotely. Creating..."
  gh repo create "$FULL_REPO" --public --source . --remote origin --push --confirm || gh repo create "$FULL_REPO" --private --source . --remote origin --push --confirm || true
fi

git add . || true
if git diff --cached --exit-code >/dev/null 2>&1; then
  echo "No changes to commit"
else
  git commit -m "Initial commit" || true
fi

git push -u origin main || git push -u origin HEAD:main

echo "Repo connected and pushed: $FULL_REPO"

if [ -n "${DOCKERHUB_TOKEN:-}" ] || [ -n "${DOCKERHUB_USERNAME:-}" ]; then
  echo "Setting Docker Hub secrets via gh (if provided)"
  ./scripts/setup-secrets.sh || true
fi

echo "Done. Use ./scripts/setup-secrets.sh to add any additional secrets."
