#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/backend"
[ ! -f ".env" ] && cp .env.example .env
[ ! -d "node_modules" ] && npm install
echo "[backend] Starting on http://localhost:3000 ..."
node src/index.js
