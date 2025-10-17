#!/bin/sh
set -e

echo "✅ Generating serve config..."
npx tsx /app/src/index.ts

if [ -f "$TS_SERVE_CONFIG" ]; then
  echo "Found serve config at $TS_SERVE_CONFIG"
else
  echo "No serve config found, continuing without it."
fi

echo "🚀 Starting Tailscale (delegating to base image logic)..."
exec /usr/local/bin/containerboot