#!/usr/bin/env bash
# Cross-platform upgrade script for Git on Linux/macOS
# Usage: sudo ./scripts/upgrade-git.sh or run with appropriate package manager perms

set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  echo "Found Homebrew; upgrading git via brew"
  brew update && brew upgrade git || brew install git
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  echo "Found apt-get; upgrading git via apt"
  sudo apt-get update && sudo apt-get install --only-upgrade -y git || sudo apt-get install -y git
  exit 0
fi

if command -v yum >/dev/null 2>&1; then
  echo "Found yum; upgrading git via yum"
  sudo yum update -y git || sudo yum install -y git
  exit 0
fi

if command -v dnf >/dev/null 2>&1; then
  echo "Found dnf; upgrading git via dnf"
  sudo dnf upgrade --refresh -y git || sudo dnf install -y git
  exit 0
fi

if command -v pacman >/dev/null 2>&1; then
  echo "Found pacman; upgrading git via pacman"
  sudo pacman -Syu --noconfirm git
  exit 0
fi

echo "No supported package manager detected. Please upgrade Git manually via your OS package manager, or download from https://git-scm.com/downloads"
exit 1
