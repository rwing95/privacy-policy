#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ ! -d "$SCRIPT_DIR/flutter_app" ]; then
  echo "[error] flutter_app/ not found. Run ./setup.sh first."
  exit 1
fi

echo "[start] Starting backend..."
bash "$SCRIPT_DIR/start_backend.sh" &
BACKEND_PID=$!

echo "[start] Waiting for backend to be ready..."
until curl -s http://localhost:3000/health >/dev/null 2>&1; do sleep 1; done
echo "[start] Backend is up."

echo "[start] Launching Flutter app..."
bash "$SCRIPT_DIR/start_app.sh"

wait $BACKEND_PID
