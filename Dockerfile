FROM node:22-alpine AS builder

WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install --omit=dev
COPY src ./src

FROM tailscale/tailscale:latest

# Copy only your code generator
COPY --from=builder /app /app

# Install Node runtime + tsx
RUN apk add --no-cache nodejs npm && npm install -g tsx

# Copy your external entrypoint script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Environment variables compatible with the official Tailscale image
ENV TS_STATE_DIR=/var/lib/tailscale \
    TS_USERSPACE=false \
    TS_SERVE_CONFIG=/config/serve.json

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]