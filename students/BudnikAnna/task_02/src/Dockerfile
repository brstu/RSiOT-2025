FROM node:22-alpine AS builder
WORKDIR /app

COPY package.json ./
RUN npm install --omit=dev && npm cache clean --force

COPY server.js ./

FROM node:22-alpine AS runtime
WORKDIR /app

RUN addgroup -S app && adduser -S -G app -u 10001 app

ENV NODE_ENV=production
ENV PORT=8083

COPY --from=builder /app /app

EXPOSE 8083

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8083/live > /dev/null 2>&1 || exit 1

USER 10001:10001

CMD ["node", "server.js"]
