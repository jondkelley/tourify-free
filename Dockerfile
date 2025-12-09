# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM deps AS builder
WORKDIR /app
COPY . .
RUN npm run build:js

FROM node:20-bullseye-slim AS production
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app /app
RUN npm prune --omit=dev \
  && rm -rf ~/.npm
RUN chown -R node:node /app
USER node
EXPOSE 3000
CMD ["node", "server.js"]
