const express = require('express');
const router = express.Router();
const axios = require('axios');

const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:3000';
const APP_SCHEME = 'steamcompanion';

router.get('/steam', (req, res) => {
  const params = new URLSearchParams({
    'openid.ns': 'http://specs.openid.net/auth/2.0',
    'openid.mode': 'checkid_setup',
    'openid.return_to': `${BACKEND_URL}/auth/steam/return`,
    'openid.realm': BACKEND_URL,
    'openid.identity': 'http://specs.openid.net/auth/2.0/identifier_select',
    'openid.claimed_id': 'http://specs.openid.net/auth/2.0/identifier_select',
  });
  res.redirect(`https://steamcommunity.com/openid/login?${params}`);
});

router.get('/steam/return', async (req, res) => {
  try {
    const claimedId = req.query['openid.claimed_id'];

    if (!claimedId) {
      return res.redirect(`${APP_SCHEME}://auth/callback?error=no_claimed_id`);
    }

    const verifyParams = { ...req.query, 'openid.mode': 'check_authentication' };
    const verifyResponse = await axios.post(
      'https://steamcommunity.com/openid/login',
      new URLSearchParams(verifyParams).toString(),
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
    );

    if (!verifyResponse.data.includes('is_valid:true')) {
      return res.redirect(`${APP_SCHEME}://auth/callback?error=verification_failed`);
    }

    const steamIdMatch = claimedId.match(/\/openid\/id\/(\d+)$/);
    if (!steamIdMatch) {
      return res.redirect(`${APP_SCHEME}://auth/callback?error=invalid_steam_id`);
    }

    const steamId = steamIdMatch[1];
    res.redirect(`${APP_SCHEME}://auth/callback?steamId=${steamId}`);
  } catch (error) {
    console.error('Auth callback error:', error.message);
    res.redirect(`${APP_SCHEME}://auth/callback?error=server_error`);
  }
});

module.exports = router;
