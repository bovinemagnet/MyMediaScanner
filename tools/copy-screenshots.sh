#!/usr/bin/env bash
# Copy raw screenshots from build/screenshots/ into the Antora asset tree
# without re-running the integration-test tour.
#
# Use this when you have just run the tour manually (or a single
# testWidgets case) and only want to refresh the committed PNGs.
#
# Usage:
#   tools/copy-screenshots.sh
#
# Author: Paul Snow
# Since: 0.0.0

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

RAW_DIR="build/screenshots"
DOCS_DIR="src/docs/modules/ROOT/images/screenshots"

if [[ ! -d "$RAW_DIR" ]]; then
  echo "ERROR: $RAW_DIR does not exist." >&2
  echo "       Run tools/capture-screenshots.sh first, or run" >&2
  echo "       'flutter test integration_test/screenshot_tour_test.dart -d linux'." >&2
  exit 1
fi

SHOT_COUNT=$(find "$RAW_DIR" -maxdepth 1 -type f -name '*.png' | wc -l)
if [[ "$SHOT_COUNT" -eq 0 ]]; then
  echo "ERROR: No PNGs in $RAW_DIR." >&2
  exit 1
fi

mkdir -p "$DOCS_DIR"

echo "==> Copying $SHOT_COUNT screenshot(s) from $RAW_DIR into $DOCS_DIR"
cp "$RAW_DIR"/*.png "$DOCS_DIR"/

echo "==> Done. Files in $DOCS_DIR:"
ls -lh "$DOCS_DIR" | tail -n +2
