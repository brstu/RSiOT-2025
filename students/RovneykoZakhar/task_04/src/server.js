const express = require('express');
const { Client } = require('pg');
const promClient = require('prom-client');

const app = express();
const port = process.env.PORT || 8004;
const METRIC_PREFIX = process.env.METRIC_PREFIX || 'app42_';

const register = new promClient.Registry();
register.setDefaultLabels({ service: 'app-v40' });
promClient.collectDefaultMetrics({ prefix: METRIC_PREFIX, register });

const requestCounter = new promClient.Counter({
  name: `${METRIC_PREFIX}http_requests_total`,
  help: 'Total HTTP requests',
  labelNames: ['method', 'path', 'status'],
});
register.registerMetric(requestCounter);

const latencyHistogram = new promClient.Histogram({
  name: `${METRIC_PREFIX}http_request_duration_seconds`,
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path', 'status'],
  buckets: [0.025, 0.05, 0.1, 0.25, 0.5, 1, 2, 5]
});
register.registerMetric(latencyHistogram);

const statusGauge = new promClient.Gauge({
  name: `${METRIC_PREFIX}service_status`,
  help: 'Service status: 1=up, 0=degraded, -1=down',
});
register.registerMetric(statusGauge);

const client = new Client({
  host: process.env.POSTGRES_HOST,
  port: process.env.POSTGRES_PORT,
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
});
client.connect().catch(console.error);

app.use((req, res, next) => {
  const end = latencyHistogram.startTimer();
  res.on('finish', () => {
    requestCounter.inc({ method: req.method, path: req.path, status: res.statusCode });
    end({ method: req.method, path: req.path, status: res.statusCode });
  });
  next();
});

app.get('/ping', async (req, res) => {
  try {
    await client.query('SELECT 1');
    statusGauge.set(1);
    res.status(200).send('OK');
  } catch {
    statusGauge.set(0);
    res.status(500).send('DB connection failed');
  }
});

app.get('/', async (req, res) => {
  try {
    const result = await client.query('SELECT NOW()');
    res.send(`Postgres says: ${result.rows[0].now}`);
  } catch {
    res.status(500).send('Error querying Postgres');
  }
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

const server = app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

process.on('SIGTERM', async () => {
  await client.end();
  server.close(() => process.exit(0));
});
