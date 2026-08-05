#!/usr/bin/env bash
# Render the privacy policy from its AsciiDoc source into the standalone HTML
# page published by GitHub Pages.
#
# GitHub Pages cannot render AsciiDoc (jekyll-asciidoc is not an allowed
# plugin), and Google Play requires a privacy policy URL that actually
# displays, so the .adoc source is converted to HTML and committed.
#
# Run this after editing the source, and commit both files together.
#
# Usage:
#   tools/render-privacy-policy.sh
#   tools/render-privacy-policy.sh --check   # verify the HTML is up to date
#
# Requires asciidoctor 2.0.23 — the same version CI pins, so that --check
# compares content rather than renderer differences:
#
#   gem install asciidoctor -v 2.0.23
#
# Author: Paul Snow
# Since: 0.0.0

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# `gem install --user-install` puts the binary somewhere that is often not on
# PATH, so look there before giving up.
if ! command -v asciidoctor >/dev/null 2>&1 && command -v ruby >/dev/null 2>&1; then
  PATH="$(ruby -e 'print Gem.user_dir')/bin:${PATH}"
  export PATH
fi

SRC="src/docs/modules/ROOT/pages/privacy-policy.adoc"
OUT="docs/privacy-policy.html"
CHECK_ONLY=false

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
fi

if [[ ! -f "$SRC" ]]; then
  echo "ERROR: $SRC not found" >&2
  exit 1
fi

# -a nofooter drops the generation timestamp, so identical input always
# produces identical output and the --check diff stays meaningful.
render() {
  local target="$1"
  local -a args=(
    --backend html5
    --doctype article
    --out-file "$target"
    -a nofooter
    -a toc!
    -a sectanchors
    # A privacy policy should not itself phone home. The default stylesheet
    # links Google Fonts from a CDN; webfonts! drops that so the page makes
    # no external requests.
    -a webfonts!
    -a lang=en-GB
    -a "docname=privacy-policy"
    "$SRC"
  )

  if ! command -v asciidoctor >/dev/null 2>&1; then
    echo "ERROR: asciidoctor not found." >&2
    echo "       Install with: gem install asciidoctor -v 2.0.23" >&2
    exit 1
  fi
  asciidoctor "${args[@]}"
}

if [[ "$CHECK_ONLY" == true ]]; then
  TMP_OUT="$(mktemp -t privacy-policy.XXXXXX).html"
  trap 'rm -f "$TMP_OUT"' EXIT
  render "$TMP_OUT"
  if ! diff -q "$OUT" "$TMP_OUT" >/dev/null 2>&1; then
    echo "ERROR: $OUT is out of date with $SRC." >&2
    echo "       Run tools/render-privacy-policy.sh and commit the result." >&2
    diff -u "$OUT" "$TMP_OUT" >&2 || true
    exit 1
  fi
  echo "==> $OUT is up to date"
  exit 0
fi

render "$OUT"
echo "==> Wrote $OUT"
echo "    Published at https://bovinemagnet.github.io/MyMediaScanner/privacy-policy.html"
