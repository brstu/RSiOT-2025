// src/server.js (Node/Express сервер для варианта 10 ЛР01 + ЛР02)

const express = require('express');
const { Pool } = require('pg');
const os = require('os');
const process = require('process');

const app = express();
app.use(express.json());

const pool = new Pool({
  user: process.env.PG_USER || 'postgres',
  host: process.env.PG_HOST || 'postgres',
  database: process.env.PG_DB || 'calc_history',
  password: process.env.PG_PASSWORD || 'secret',
  port: 5432,
});

// Инициализация таблицы при старте (graceful)
async function initDb() {
  const client = await pool.connect();
  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS history (
        id SERIAL PRIMARY KEY,
        operation TEXT NOT NULL,
        result TEXT NOT NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
  } finally {
    client.release();
  }
}

// Health endpoint (по варианту 10 ЛР01: /ping)
app.get('/ping', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).send('OK');
  } catch (err) {
    res.status(500).send('DB ERROR');
  }
});

// Readiness endpoint (для K8s probes)
app.get('/ready', (req, res) => res.status(200).send('READY'));

// Calc endpoint
app.get('/calc', async (req, res) => {
  const { a, b, op } = req.query;
  if (!a || !b || !op) return res.status(400).send('Missing params');

  let result;
  const numA = parseFloat(a);
  const numB = parseFloat(b);

  switch (op) {
    case 'add': result = numA + numB; break;
    case 'sub': result = numA - numB; break;
    case 'mul': result = numA * numB; break;
    case 'div':
      if (numB === 0) return res.status(400).send('Division by zero');
      result = numA / numB;
      break;
    default: return res.status(400).send('Unknown op');
  }

  const entry = `${a} ${op} ${b} = ${result.toFixed(2)}`;

  try {
    await pool.query('INSERT INTO history (operation, result) VALUES ($1, $2)', [entry, result.toFixed(2)]);
    res.send(result.toFixed(2));
  } catch (err) {
    res.status(500).send('DB insert error');
  }
});

// History endpoint
app.get('/history', async (req, res) => {
  try {
    const { rows } = await pool.query('SELECT operation FROM history ORDER BY timestamp DESC LIMIT 50');
    res.json(rows.map(row => row.operation));
  } catch (err) {
    res.status(500).send('DB query error');
  }
});

const port = process.env.APP_PORT || 8072;

const server = app.listen(port, async () => {
  console.log(`Starting service on port ${port}. STU_ID=${process.env.STU_ID} STU_GROUP=${process.env.STU_GROUP} STU_VARIANT=10`);
  await initDb();
  console.log('DB initialized');
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received. Shutting down...');
  server.close(() => {
    pool.end(() => {
      console.log('DB pool closed. Exiting.');
      process.exit(0);
    });
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received. Shutting down...');
  server.close(() => {
    pool.end(() => {
      console.log('DB pool closed. Exiting.');
      process.exit(0);
    });
  });
});