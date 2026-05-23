#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FLUTTER_DIR="$SCRIPT_DIR/flutter_app"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "[error] flutter_app/ not found. Run ./setup.sh first."
  exit 1
fi

cd "$FLUTTER_DIR"
echo "[app] Launching Flutter app..."
flutter run
