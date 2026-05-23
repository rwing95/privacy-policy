const express = require('express');
const router = express.Router();
const axios = require('axios');

const STEAM_API = 'https://api.steampowered.com';
const STEAM_STORE_API = 'https://store.steampowered.com';

router.get('/profile/:steamId', async (req, res) => {
  const { steamId } = req.params;
  const { apiKey } = req.query;
  if (!apiKey) return res.status(400).json({ error: 'API key required' });

  try {
    const response = await axios.get(`${STEAM_API}/ISteamUser/GetPlayerSummaries/v0002/`, {
      params: { key: apiKey, steamids: steamId },
    });
    const players = response.data?.response?.players || [];
    res.json(players[0] || null);
  } catch (error) {
    console.error('Profile fetch error:', error.message);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

router.get('/games/:steamId', async (req, res) => {
  const { steamId } = req.params;
  const { apiKey } = req.query;
  if (!apiKey) return res.status(400).json({ error: 'API key required' });

  try {
    const response = await axios.get(`${STEAM_API}/IPlayerService/GetOwnedGames/v0001/`, {
      params: {
        key: apiKey,
        steamid: steamId,
        include_appinfo: true,
        include_played_free_games: true,
      },
    });
    res.json(response.data?.response || { games: [], game_count: 0 });
  } catch (error) {
    console.error('Games fetch error:', error.message);
    res.status(500).json({ error: 'Failed to fetch games' });
  }
});

router.get('/wishlist/:steamId', async (req, res) => {
  const { steamId } = req.params;
  try {
    const response = await axios.get(
      `${STEAM_STORE_API}/wishlist/profiles/${steamId}/wishlistdata/`,
      { headers: { Accept: 'application/json' }, timeout: 10000 }
    );
    res.json(response.data || {});
  } catch (error) {
    console.error('Wishlist fetch error:', error.message);
    res.status(500).json({ error: 'Failed to fetch wishlist' });
  }
});

router.get('/achievements/:steamId/:appId', async (req, res) => {
  const { steamId, appId } = req.params;
  const { apiKey } = req.query;
  if (!apiKey) return res.status(400).json({ error: 'API key required' });

  try {
    const response = await axios.get(
      `${STEAM_API}/ISteamUserStats/GetPlayerAchievements/v0001/`,
      { params: { key: apiKey, steamid: steamId, appid: appId } }
    );
    res.json(response.data?.playerstats || { achievements: [] });
  } catch (error) {
    console.error('Achievements fetch error:', error.message);
    res.status(200).json({ achievements: [], error: 'No achievement data available' });
  }
});

router.get('/recent/:steamId', async (req, res) => {
  const { steamId } = req.params;
  const { apiKey } = req.query;
  if (!apiKey) return res.status(400).json({ error: 'API key required' });

  try {
    const response = await axios.get(
      `${STEAM_API}/IPlayerService/GetRecentlyPlayedGames/v0001/`,
      { params: { key: apiKey, steamid: steamId, count: 10 } }
    );
    res.json(response.data?.response || { games: [] });
  } catch (error) {
    console.error('Recent games fetch error:', error.message);
    res.status(500).json({ error: 'Failed to fetch recent games' });
  }
});

module.exports = router;
