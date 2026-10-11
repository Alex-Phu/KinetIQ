#!/usr/bin/env bash
# Run the KinetIQ backend (port 8000) and frontend (port 3000) together.
# Ctrl+C stops both. If either one exits, the other is stopped too.
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_PORT=8000  # frontend/src/App.jsx calls http://localhost:8000
UVICORN="$ROOT/backend/venv/bin/uvicorn"

if [[ ! -x "$UVICORN" ]]; then
  echo "error: $UVICORN not found. Create backend/venv and install backend/requirements.txt first." >&2
  exit 1
fi
if [[ ! -d "$ROOT/frontend/node_modules" ]]; then
  echo "error: frontend/node_modules missing. Run 'npm install' in frontend/ first." >&2
  exit 1
fi
if lsof -nP -iTCP:"$BACKEND_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "error: port $BACKEND_PORT is already in use:" >&2
  lsof -nP -iTCP:"$BACKEND_PORT" -sTCP:LISTEN >&2
  exit 1
fi

BACKEND_PID=""
FRONTEND_PID=""

# Kill a process and all of its descendants (npm -> sh -> node/vite).
kill_tree() {
  local pid=$1 child
  for child in $(pgrep -P "$pid" 2>/dev/null); do
    kill_tree "$child"
  done
  kill "$pid" 2>/dev/null || true
}

cleanup() {
  trap - INT TERM EXIT
  echo
  echo "Stopping backend and frontend..."
  [[ -n "$BACKEND_PID" ]] && kill_tree "$BACKEND_PID"
  [[ -n "$FRONTEND_PID" ]] && kill_tree "$FRONTEND_PID"
  wait 2>/dev/null
  echo "Stopped."
}
trap 'cleanup; exit 130' INT TERM
trap cleanup EXIT

"$UVICORN" main:app --app-dir "$ROOT/backend" --port "$BACKEND_PORT" &
BACKEND_PID=$!

(cd "$ROOT/frontend" && exec npm run dev) &
FRONTEND_PID=$!

echo "Backend:  http://localhost:$BACKEND_PORT  (pid $BACKEND_PID)"
echo "Frontend: http://localhost:3000  (pid $FRONTEND_PID)"
echo "Press Ctrl+C to stop both."

# bash 3.2 (macOS default) has no 'wait -n', so poll until either process exits.
while kill -0 "$BACKEND_PID" 2>/dev/null && kill -0 "$FRONTEND_PID" 2>/dev/null; do
  sleep 1
done
echo "One of the processes exited; shutting down the other."
