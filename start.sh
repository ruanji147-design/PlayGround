#!/usr/bin/env bash
# PlayGround static server: serve dist/ in the foreground, publish deployment output.
set -euo pipefail
cd "$(dirname "$0")"

PROJECT_ROOT="/home/runner/work/PlayGround/PlayGround"
DIST_DIR="$PROJECT_ROOT/dist"
PORT="${PORT:-3000}"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
OUTPUT_FILE="$WEB_DIR/deployment-output.json"

/usr/bin/time -p mkdir -p "$DIST_DIR"
/usr/bin/time -p mkdir -p "$WEB_DIR"
if [ -f "$PROJECT_ROOT/package.json" ]; then
  if [ -f "$PROJECT_ROOT/package-lock.json" ]; then
    /usr/bin/time -p npm --prefix "$PROJECT_ROOT" ci --no-audit --no-fund
  else
    /usr/bin/time -p npm --prefix "$PROJECT_ROOT" install --no-audit --no-fund
  fi
  if /usr/bin/time -p node -e "const p=require('$PROJECT_ROOT/package.json');process.exit(p.scripts&&p.scripts.build?0:1)"; then
    /usr/bin/time -p npm --prefix "$PROJECT_ROOT" run build
  fi
fi
/usr/bin/time -p test -f "$DIST_DIR/index.html"
/usr/bin/time -p bash -c 'printf "%s" "{\"project\":\"/home/runner/work/PlayGround/PlayGround\",\"directory\":\"/home/runner/work/PlayGround/PlayGround/dist\"}" > "$1"' _ "$OUTPUT_FILE"
/usr/bin/time -p cat "$OUTPUT_FILE"
/usr/bin/time -p python3 -m http.server "$PORT" --directory "$DIST_DIR" --bind 0.0.0.0
