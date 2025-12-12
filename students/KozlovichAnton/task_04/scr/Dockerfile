FROM node:18-alpine AS build
WORKDIR /app
COPY src/package.json ./
RUN npm install --production
COPY src/ ./

FROM node:18-alpine
WORKDIR /app
COPY --from=build /app /app
RUN chown -R node:node /app
USER node
ENV PORT=8080
ENV METRICS_PREFIX=app07_
EXPOSE 8080
CMD ["node", "index.js"]
