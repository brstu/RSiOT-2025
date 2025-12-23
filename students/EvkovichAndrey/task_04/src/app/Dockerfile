FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY . .

USER 65532
ENV PORT=8023
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
EXPOSE 8023

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8023/health || exit 1

LABEL org.opencontainers.image.source="https://github.com/<your-github>/lab01-docker" \
      org.opencontainers.image.description="ЛР01 по контейнеризации, вариант 31" \
      org.opencontainers.image.licenses="MIT" \
      org.bstu.student.fullname="Евкович Андрей Викторович" \
      org.bstu.student.id="220039" \
      org.bstu.group="АС-64" \
      org.bstu.variant="31" \
      org.bstu.course="RSIOT"

ENV PORT=8012 \
    NODE_ENV=production

CMD ["node", "server.js"]