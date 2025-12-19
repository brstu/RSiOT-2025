FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY src/server.js ./

# Используем distroless образ для Node.js 20
FROM node:20-slim AS runtime
WORKDIR /app

# Копируем только нужные файлы из сборки
COPY --from=build /app /app

# Используем команду через PATH — это сработает и в официальном образе Node
ENTRYPOINT ["node", "server.js"]

EXPOSE 8072

# Healthcheck через node на PATH
HEALTHCHECK --interval=10s --timeout=3s --start-period=15s --retries=3 \
  CMD ["node", "-e", "require('http').get('http://127.0.0.1:8072/ping', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"]
