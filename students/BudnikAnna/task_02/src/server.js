const http = require('http');

const PORT = Number(process.env.PORT || 8083);
const APP_ENV = process.env.APP_ENV || 'prod';

let isReady = false;
let isShuttingDown = false;

function log(level, msg, extra = {}) {
  const entry = {
    ts: new Date().toISOString(),
    level,
    msg,
    ...extra,
  };
  console.log(JSON.stringify(entry));
}

function send(res, code, body, headers = {}) {
  const payload = typeof body === 'string' ? body : JSON.stringify(body);
  res.writeHead(code, { 'content-type': 'application/json; charset=utf-8', ...headers });
  res.end(payload);
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const path = url.pathname;

  log('info', 'request', { method: req.method, path });

  if (path === '/' || path === '/ping') {
    return send(res, 200, { ok: true, service: 'web03', env: APP_ENV, port: PORT });
  }

  if (path === '/live') {
    return send(res, 200, { ok: true, live: true });
  }

  if (path === '/ready') {
    if (isReady && !isShuttingDown) return send(res, 200, { ok: true, ready: true });
    return send(res, 503, { ok: false, ready: false, shuttingDown: isShuttingDown });
  }

  return send(res, 404, { ok: false, error: 'not_found' });
});

function shutdown(signal) {
  if (isShuttingDown) return;
  isShuttingDown = true;
  isReady = false;

  log('warn', 'shutdown_started', { signal });

  server.close((err) => {
    if (err) {
      log('error', 'shutdown_error', { error: err.message });
      process.exit(1);
    }
    log('info', 'shutdown_completed');
    process.exit(0);
  });

  const timeoutMs = Number(process.env.SHUTDOWN_TIMEOUT_MS || 10000);
  setTimeout(() => {
    log('error', 'shutdown_force_exit', { timeoutMs });
    process.exit(1);
  }, timeoutMs).unref();
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

server.listen(PORT, '0.0.0.0', () => {
  isReady = true;
  log('info', 'server_started', { port: PORT, env: APP_ENV, pid: process.pid });
});
