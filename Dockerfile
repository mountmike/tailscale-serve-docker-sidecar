FROM node:22-alpine AS builder

WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install --omit=dev
COPY src ./src

FROM tailscale/tailscale:latest

COPY --from=builder /app /app

RUN apk add --no-cache nodejs npm && npm install -g tsx

ENV TS_STATE_DIR=/var/lib/tailscale \
    TS_USERSPACE=false \
    TS_AUTH_ONCE=true \
    TS_SERVE_CONFIG=/config/serve.json

# Run generator, then start tailscaled
ENTRYPOINT ["/bin/sh", "-c", "generate-serve-config && exec tailscaled --state=/var/lib/tailscale/tailscaled.state"]