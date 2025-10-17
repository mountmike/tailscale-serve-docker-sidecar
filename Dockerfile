FROM node:22-alpine AS builder

WORKDIR /app
COPY package.json tsconfig.json ./
RUN npm install --omit=dev
COPY src ./src

FROM tailscale/tailscale:latest

# Copy only your code generator
COPY --from=builder /app /app

RUN apk add --no-cache nodejs npm && npm install -g tsx

ENV TS_STATE_DIR=/var/lib/tailscale \
    TS_USERSPACE=false \
    TS_SERVE_CONFIG=/config/serve.json

# Wrapper entrypoint that preps the serve.json, then hands off to the base image logic
COPY <<'EOF' /entrypoint.sh
#!/bin/sh
set -e

echo "✅ Generating serve config..."
npx tsx /app/src/index.ts

echo "🚀 Starting Tailscale (delegating to base image logic)..."
exec /usr/local/bin/containerboot
EOF

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]