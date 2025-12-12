FROM node:22-alpine

WORKDIR /app

RUN addgroup -S app && adduser -S -u 10001 -G app app

COPY package*.json ./
RUN npm install

COPY ./src ./src

USER app

EXPOSE 8084

CMD ["node", "src/index.js"]
