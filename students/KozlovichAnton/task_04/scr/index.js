const express = require('express');
const promClient = require('prom-client');
const http = require('http');

const PORT = process.env.PORT || 8080;
const METRICS_PREFIX = process.env.METRICS_PREFIX || 'app07_';

const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestTotal = new promClient.Counter({
  name: `${METRICS_PREFIX}http_requests_total`,
  help: 'Total HTTP requests',
  labelNames: ['code', 'method', 'path']
});

const httpRequestDuration = new promClient.Histogram({
  name: `${METRICS_PREFIX}http_request_duration_seconds`,
  help: 'Request duration seconds',
  labelNames: ['path', 'method'],
  buckets: [0.005,0.01,0.025,0.05,0.1,0.25,0.5,1,2,5]
});

register.registerMetric(httpRequestTotal);
register.registerMetric(httpRequestDuration);

const app = express();

app.use((req, res, next) => {
  res._start = process.hrtime();
  const end = res.end;
  res.end = function (chunk, encoding) {
    const elapsed = process.hrtime(res._start);
    const seconds = elapsed[0] + elapsed[1] / 1e9;
    const code = res.statusCode || 200;
    httpRequestTotal.labels(String(code), req.method, req.path).inc();
    httpRequestDuration.labels(req.path, req.method).observe(seconds);
    end.call(this, chunk, encoding);
  };
  next();
});

app.get('/', (req, res) => {
  const delayMs = Math.floor(Math.random() * 700);
  setTimeout(() => {
    if (req.query.fail === '1') {
      res.status(500).send('internal error\n');
      return;
    }
    res.send(`OK (delay=${delayMs}ms)\n`);
  }, delayMs);
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

const server = http.createServer(app);

server.listen(PORT, () => console.log(`LR04 metrics server listening on ${PORT}`));

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

function shutdown(sig) {
  console.log(`Received ${sig}, shutting down`);
  server.close(() => process.exit(0));
  setTimeout(() => process.exit(1), 5000).unref();
}
