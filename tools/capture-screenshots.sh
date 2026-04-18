#!/usr/bin/env bash
# Capture documentation screenshots by running the integration-test tour
# and copying the produced PNGs into the Antora asset tree.
#
# Usage:
#   tools/capture-screenshots.sh
#
# Requires a desktop session (a display), not a headless environment.
# Headless CI needs Xvfb or similar — the integration test pumps the real
# Flutter app and cannot render on a null display.
#
# Author: Paul Snow
# Since: 0.0.0

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RAW_DIR="build/screenshots"
DOCS_DIR="src/docs/modules/ROOT/assets/images/screenshots"

echo "==> Cleaning previous raw captures"
rm -rf "$RAW_DIR"
mkdir -p "$RAW_DIR"
mkdir -p "$DOCS_DIR"

echo "==> Running screenshot tour (flutter test -d linux)"
flutter test integration_test/screenshot_tour_test.dart -d linux

SHOT_COUNT=$(find "$RAW_DIR" -maxdepth 1 -type f -name '*.png' | wc -l)
if [[ "$SHOT_COUNT" -eq 0 ]]; then
  echo "ERROR: No screenshots produced in $RAW_DIR" >&2
  echo "       Make sure the test ran on a real display, not headless." >&2
  exit 1
fi

echo "==> Copying $SHOT_COUNT screenshot(s) into $DOCS_DIR"
cp "$RAW_DIR"/*.png "$DOCS_DIR"/

echo "==> Done. Files in $DOCS_DIR:"
ls -lh "$DOCS_DIR" | tail -n +2
