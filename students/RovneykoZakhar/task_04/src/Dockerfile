FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules
COPY . .

USER 10001
ENV PORT=8004
ENV POSTGRES_HOST=postgres
ENV POSTGRES_PORT=5432
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=mydb
EXPOSE 8004

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8004/ping || exit 1

LABEL org.opencontainers.image.source="https://github.com/" \
      org.opencontainers.image.description="ЛР01 по контейнеризации, вариант 40" \
      org.opencontainers.image.licenses="MIT" \
      org.bstu.student.fullname="Ровнейко Захар Сергеевич" \
      org.bstu.student.id="220022" \
      org.bstu.group="АС-64" \
      org.bstu.variant="40" \
      org.bstu.course="RSIOT"

ENV NODE_ENV=production

CMD ["node", "server.js"]
