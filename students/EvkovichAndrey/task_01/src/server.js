const express = require('express');
const redis = require('redis');

const app = express();
const port = process.env.PORT || 8023;

const client = redis.createClient({
  url: `redis://${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`
});

client.connect().catch(console.error);

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.get('/', async (req, res) => {
  await client.set('ping', 'pong');
  const value = await client.get('ping');
  res.send(`Redis says: ${value}`);
});

const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  await client.quit();
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});
