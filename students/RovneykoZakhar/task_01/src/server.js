const express = require('express');
const { Client } = require('pg');

const app = express();
const port = process.env.PORT || 8004;

const client = new Client({
  host: process.env.POSTGRES_HOST,
  port: process.env.POSTGRES_PORT,
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});

client.connect().catch(console.error);

app.get('/ping', async (req, res) => {
  try {
    await client.query('SELECT 1');
    res.status(200).send('OK');
  } catch (err) {
    res.status(500).send('DB connection failed');
  }
});

app.get('/', async (req, res) => {
  try {
    const result = await client.query('SELECT NOW()');
    res.send(`Postgres says: ${result.rows[0].now}`);
  } catch (err) {
    res.status(500).send('Error querying Postgres');
  }
});

const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');
  await client.end();
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});
