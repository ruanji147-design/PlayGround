#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"
/usr/bin/time -p printf 'PROJECT_DIR=%s\n' "$PROJECT_DIR"
/usr/bin/time -p bash -c 'test -f dist/index.html || { echo "dist/index.html missing" >&2; exit 1; }'
DIST_DIR="$PROJECT_DIR/dist"
PORT="${PORT:-3000}"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
/usr/bin/time -p mkdir -p "$DIST_DIR" "$WEB_DIR"
/usr/bin/time -p bash -c '
  if [ -f package.json ]; then
    if [ -f package-lock.json ]; then npm ci --no-audit --no-fund; else npm install --no-audit --no-fund; fi
    if grep -q "\"build\"" package.json; then npm run build; fi
  else
    echo "no package.json, static dist only"
  fi
'
/usr/bin/time -p python3 -c '
import json, os
project = os.getcwd()
dist = os.path.join(project, "dist")
web = os.environ.get("OPENCODE_WEB_DIR", "/home/runner/work/_temp/omgithub-web")
os.makedirs(web, exist_ok=True)
out = os.path.join(web, "deployment-output.json")
with open(out, "w") as f:
    json.dump({"project": project, "directory": dist}, f)
print("wrote", out)
'
/usr/bin/time -p python3 -c 'import json,os; p=os.path.join(os.environ.get("OPENCODE_WEB_DIR","/home/runner/work/_temp/omgithub-web"),"deployment-output.json"); print(open(p).read())'
/usr/bin/time -p python3 -m http.server "$PORT" --directory "$DIST_DIR"
