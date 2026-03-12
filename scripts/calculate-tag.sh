#!/bin/bash
set -euo pipefail

# Get the current branch name
BRANCH_NAME="${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}"

# Fetch all tags
git fetch --tags --force 2>/dev/null || true

# Get the latest semver tag (sorted by version)
LATEST_TAG=$(git tag --list 'v*' --sort=-version:refname | head -n 1)

# if not tag found, default to 1.0.0
if [ -z "$LATEST_TAG" ]; then
  echo "No semver tags found, defaulting to 1.0.0"
  VERSION="1.0.0"
else
  # Strip the leading 'v' if present
  VERSION="${LATEST_TAG#v}"
fi

if [ "$BRANCH_NAME" = "main" ]; then
  VERSION_TAG="$VERSION"
else
  # Sanitize branch name: replace / and special chars with -
  SANITIZED_BRANCH=$(echo "$BRANCH_NAME" | sed 's/[^a-zA-Z0-9._-]/-/g')

  # Generate timestamp in ddmmyyyyhhss format
  TIMESTAMP=$(date -u +"%d%m%Y%H%M")

  VERSION_TAG="${VERSION}-${SANITIZED_BRANCH}-${TIMESTAMP}"
fi

echo "Calculated version tag: $VERSION_TAG"

# Write to GitHub Actions output if running in CI
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version_tag=$VERSION_TAG" >> "$GITHUB_OUTPUT"
fi
