const express = require('express');
const http = require('http');

const PORT = process.env.PORT || 8080;
const STU_ID = process.env.STU_ID || '220011';
const STU_GROUP = process.env.STU_GROUP || 'as-63';
const VARIANT = process.env.STU_VARIANT || '7';

const app = express();

app.get('/', (req, res) => {
  res.send(`Hello from Kozlovich LR02 (ID=${STU_ID}, group=${STU_GROUP}, variant=${VARIANT})\n`);
});

app.get('/healthz', (req, res) => res.status(200).send('ok\n'));
app.get('/readyz', (req, res) => res.status(200).send('ready\n'));

const server = http.createServer(app);

server.listen(PORT, () => {
  console.log(`LR02 server listening on ${PORT}`);
});

// graceful shutdown
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

function shutdown(signal) {
  console.log(`Received ${signal}, shutting down...`);
  server.close(() => {
    console.log('Server stopped');
    process.exit(0);
  });
  setTimeout(() => {
    console.error('Forcing shutdown');
    process.exit(1);
  }, 5000).unref();
}
