FROM node:22-alpine AS builder

WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install --omit=dev
COPY src ./src

FROM tailscale/tailscale:latest

COPY --from=builder /app /app

RUN apk add --no-cache nodejs npm && npm install -g tsx

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV TS_STATE_DIR=/var/lib/tailscale \
    TS_USERSPACE=false \
    TS_SERVE_CONFIG=/config/serve.json

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]