# Steam Companion

A Flutter mobile app (iOS + Android) with a Node.js backend that lets you sign into your Steam account and browse your game library, wishlist, and profile stats — without opening the Steam app.

---

## Quickstart

**Prerequisites:** [Node.js](https://nodejs.org) and [Flutter SDK](https://flutter.dev/docs/get-started/install)

```bash
git clone https://github.com/rwing95/steam-companion.git
cd steam-companion
./setup.sh      # one-time setup — creates Flutter project, installs all deps
./start.sh      # starts backend + launches app
```

That's it. The setup script handles everything automatically.

---

## What `setup.sh` does

1. Checks Node.js and Flutter are installed
2. Installs backend npm packages
3. Runs `flutter create` to generate the Android/iOS native scaffold
4. Copies the app source files into the scaffold
5. Runs `flutter pub get`
6. Patches the Android manifest with the required internet permission

---

## After setup — Steam API Key

The wishlist works immediately (no key needed). For your **library, achievements, and profile** you need a free Steam Web API key:

1. Visit [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey)
2. In the app → **Settings** tab → paste your key → **Save**

---

## Running on a real device

Edit `backend/.env` and set `BACKEND_URL` to your machine's local IP:

```
BACKEND_URL=http://192.168.1.x:3000
```

Then in the app's login screen tap **"Configure backend URL"** and set the same address.  
(Android emulator uses `http://10.0.2.2:3000` · iOS simulator uses `http://localhost:3000`)

---

## Project structure

```
backend/          Node.js + Express (Steam OpenID auth + Steam API proxy)
app/              Flutter source (lib/, pubspec.yaml, assets/)
flutter_app/      Generated Flutter project (created by setup.sh)
setup.sh          One-time setup script
start.sh          Start backend + app together
start_backend.sh  Start backend only
start_app.sh      Start Flutter app only
```

---

## Screens

| Screen | What it shows |
|--------|---------------|
| Login | Steam OpenID via in-app WebView |
| Library | All owned games — grid/list, search, sort by playtime/name/recent |
| Game Detail | Total playtime · recent hours · last played date · achievements |
| Wishlist | Full wishlist with review scores, release dates, priority rank |
| Profile | Avatar, status, total hours, most-played game, member since |
| Settings | API key, backend URL, sign out |

---

## Authentication flow

```
App → backend /auth/steam
    → Steam OpenID login page
    → backend /auth/steam/return  (verifies response)
    → steamcompanion://auth/callback?steamId=XXXXX
    → App intercepts in WebView → signed in
```
