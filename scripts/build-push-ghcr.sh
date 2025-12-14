#!/usr/bin/env bash
set -euo pipefail

# Build and push Docker image to GitHub Container Registry (GHCR)
# Usage: export GHCR_USERNAME=owner GHCR_TOKEN=pat ./scripts/build-push-ghcr.sh

if [ -z "${GHCR_TOKEN:-}" ] && [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Please set GHCR_TOKEN or GITHUB_TOKEN environment variable"
  exit 1
fi

REPO="${GHCR_REPOSITORY:-}"
if [ -z "$REPO" ]; then
  if git remote get-url origin >/dev/null 2>&1; then
    REMOTE=$(git remote get-url origin)
    if [[ "$REMOTE" =~ github.com[:/]([^/]+/[^/.]+) ]]; then
      REPO="${BASH_REMATCH[1]}"
    fi
  fi
fi

if [ -z "$REPO" ]; then
  echo "Could not determine repository. Set GHCR_REPOSITORY or ensure git remote origin exists." >&2
  exit 1
fi

IMAGE_NAME="ghcr.io/$REPO"
if [ -n "${DOCKER_IMAGE:-}" ]; then
  IMAGE_NAME="$DOCKER_IMAGE"
fi

echo "Image: $IMAGE_NAME"

TOKEN="${GHCR_TOKEN:-${GITHUB_TOKEN}}"
USER="${GHCR_USERNAME:-${REPO%/*}}"

echo "Logging into GHCR as $USER"
echo -n "$TOKEN" | docker login ghcr.io -u "$USER" --password-stdin

echo "Building $IMAGE_NAME:latest"
docker build -t $IMAGE_NAME:latest .

SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "local")
docker tag $IMAGE_NAME:latest $IMAGE_NAME:$SHA

echo "Pushing $IMAGE_NAME:latest and $IMAGE_NAME:$SHA"
docker push $IMAGE_NAME:latest
docker push $IMAGE_NAME:$SHA

echo "Done: $IMAGE_NAME"
