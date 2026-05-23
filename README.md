# Steam Companion

A mobile app (Flutter) with a lightweight Node.js backend that lets you sign in with your Steam account and browse your game library, wishlist, and profile stats — without opening the Steam app.

---

## Features

- **Steam OpenID login** — sign in securely via the official Steam login page
- **Game Library** — browse all owned games sorted by playtime, with grid and list views, and search
- **Game Stats** — per-game: total playtime, recent playtime (last 2 weeks), last played date, achievement progress
- **Achievements** — unlocked vs locked achievements with unlock dates
- **Wishlist** — view your full wishlist with review scores, release dates, and priority ranking
- **Profile** — avatar, status, total hours, most-played game, member since date
- **Steam-themed dark UI** matching the Steam aesthetic

---

## Project Structure

```
steam_backend/     Node.js + Express backend (Steam OpenID + API proxy)
steam_app/         Flutter mobile app (iOS + Android)
```

---

## Setup

### 1. Backend

```bash
cd steam_backend
npm install
cp .env.example .env
# Edit .env — set BACKEND_URL to your machine's reachable address
node src/index.js
```

The backend runs on port `3000` by default.

**Finding your local IP (for real device testing):**
- macOS/Linux: `ifconfig | grep "inet "`
- Windows: `ipconfig`

### 2. Flutter App

**Prerequisites:** Flutter SDK installed ([flutter.dev](https://flutter.dev/docs/get-started/install))

```bash
cd steam_app
flutter pub get
flutter run
```

On first launch, tap **"Configure backend URL"** on the login screen and set the address:
- Android emulator → `http://10.0.2.2:3000`
- iOS simulator → `http://localhost:3000`
- Real device → `http://<your-machine-ip>:3000`

### 3. Steam Web API Key (for library & profile data)

1. Visit [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey) (free, instant)
2. Open the app → **Settings** tab → paste your key → **Save Settings**

The wishlist works without an API key (it uses Steam's public store endpoint).

---

## Authentication Flow

```
App → Backend /auth/steam
   → Steam OpenID login page
   → Backend /auth/steam/return  (verifies the OpenID response)
   → steamcompanion://auth/callback?steamId=XXXXX
   → App intercepts redirect in WebView → logs in
```

---

## Android Permissions

In `android/app/src/main/AndroidManifest.xml`, ensure this is present inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## Screens

| Screen | Description |
|--------|-------------|
| Login | Steam OpenID via in-app WebView |
| Library | Owned games grid/list with search & sort |
| Game Detail | Per-game stats, playtime, achievements |
| Wishlist | Prioritized wishlist with reviews & release dates |
| Profile | Avatar, stats overview, most-played game |
| Settings | API key, backend URL, sign out |
