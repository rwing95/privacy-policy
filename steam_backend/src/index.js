require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/auth');
const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({ origin: '*' }));
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/api', apiRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(PORT, '0.0.0.0', () => {
  const backendUrl = process.env.BACKEND_URL || `http://localhost:${PORT}`;
  console.log(`Steam Companion backend running on port ${PORT}`);
  console.log(`Backend URL: ${backendUrl}`);
  console.log(`Steam login: ${backendUrl}/auth/steam`);
});
