#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[setup]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC}  $1"; }
fail() { echo -e "${RED}[error]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
APP_SRC_DIR="$SCRIPT_DIR/app"
FLUTTER_DIR="$SCRIPT_DIR/flutter_app"

# ── 1. Check dependencies ────────────────────────────────────────────────────

log "Checking dependencies..."
command -v node  >/dev/null 2>&1 || fail "Node.js not found. Install from https://nodejs.org"
command -v npm   >/dev/null 2>&1 || fail "npm not found. Install from https://nodejs.org"
command -v flutter >/dev/null 2>&1 || fail "Flutter not found. Install from https://flutter.dev/docs/get-started/install"

log "Node  : $(node --version)"
log "npm   : $(npm --version)"
log "Flutter: $(flutter --version | head -1)"

# ── 2. Backend setup ─────────────────────────────────────────────────────────

log "Setting up backend..."
cd "$BACKEND_DIR"

if [ ! -f ".env" ]; then
  cp .env.example .env
  warn ".env created from .env.example — edit BACKEND_URL if needed"
fi

npm install
log "Backend dependencies installed."

# ── 3. Flutter project scaffold ──────────────────────────────────────────────

if [ -d "$FLUTTER_DIR" ]; then
  warn "flutter_app/ already exists — skipping flutter create."
else
  log "Creating Flutter project scaffold..."
  flutter create \
    --project-name steam_companion \
    --org com.steamcompanion \
    --platforms android,ios \
    "$FLUTTER_DIR" >/dev/null

  log "Flutter project created."
fi

# ── 4. Copy source files into scaffold ───────────────────────────────────────

log "Copying app source files..."

cp -r "$APP_SRC_DIR/lib/"*     "$FLUTTER_DIR/lib/"
cp    "$APP_SRC_DIR/pubspec.yaml" "$FLUTTER_DIR/pubspec.yaml"
mkdir -p "$FLUTTER_DIR/assets/images"

# ── 5. Flutter packages ───────────────────────────────────────────────────────

log "Installing Flutter packages..."
cd "$FLUTTER_DIR"
flutter pub get
log "Flutter packages installed."

# ── 6. Android internet permission ────────────────────────────────────────────

MANIFEST="$FLUTTER_DIR/android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
    sed -i 's/<manifest/<manifest\n    xmlns:tools="http:\/\/schemas.android.com\/tools"/' "$MANIFEST"
    sed -i 's/<application/<uses-permission android:name="android.permission.INTERNET"\/>\n    <application/' "$MANIFEST"
    log "Added INTERNET permission to AndroidManifest.xml"
  else
    log "INTERNET permission already present."
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Start the backend:  ./start_backend.sh"
echo "  2. Run the app:        ./start_app.sh"
echo ""
echo "Or run both at once:     ./start.sh"
echo ""
echo "Before running, edit backend/.env and set BACKEND_URL to your machine's IP"
echo "if testing on a real device (e.g. http://192.168.1.x:3000)"
