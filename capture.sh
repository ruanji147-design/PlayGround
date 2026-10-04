#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p printf 'capture project: %s\n' "$(pwd)"
: "${CAPTURE_URL:?Set CAPTURE_URL.}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR.}"
RUNTIME="${RUNTIME_DIR:-/home/runner/work/_temp/omgithub-runtime}"
/usr/bin/time -p bash -c 'test -n "${CAPTURE_URL:-}" && test -n "${CAPTURE_DIR:-}" || { echo "CAPTURE_URL and CAPTURE_DIR required" >&2; exit 1; }'
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p bash -c '
  case "$CAPTURE_DIR" in
    "$PWD"/*) echo "CAPTURE_DIR must stay outside source: $CAPTURE_DIR" >&2; exit 1;;
  esac
'
set +e
/usr/bin/time -p node "$RUNTIME/scripts/default-capture.mjs"
status=$?
set -e
/usr/bin/time -p bash -c 'test -f "$CAPTURE_DIR/final-desktop.png" && test -f "$CAPTURE_DIR/final-mobile.png" || { echo "capture output missing" >&2; exit 1; }'
exit "$status"
