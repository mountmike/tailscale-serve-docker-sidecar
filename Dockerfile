FROM node:22-alpine AS builder

ARG SIDECAR_SERVE_PORT
ARG SIDECAR_SERVE_ADDRESS
ARG SIDECAR_SERVE_PATH
ARG SIDECAR_SERVE_FUNNEL

ENV SIDECAR_SERVE_PORT=${SIDECAR_SERVE_PORT} \
    SIDECAR_SERVE_ADDRESS=${SIDECAR_SERVE_ADDRESS} \
    SIDECAR_SERVE_PATH=${SIDECAR_SERVE_PATH} \
    SIDECAR_SERVE_FUNNEL=${SIDECAR_SERVE_FUNNEL}

WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install --omit=dev
COPY src ./src

RUN npx tsx src/index.ts

FROM tailscale/tailscale:latest

COPY --from=builder /config /config

ENV TS_STATE_DIR=/var/lib/tailscale \
    TS_USERSPACE=false \
    TS_SERVE_CONFIG=/config/serve.json