import fs from "fs";

const { env } = process;

const port = env.SIDECAR_SERVE_PORT;

if (!port) {
    console.error("❌ SIDECAR_SERVE_PORT is required.");
    process.exit(1);
}

const httpsEnabled = env.SIDECAR_SERVE_HTTPS !== "false";
const allowFunnel = env.SIDECAR_SERVE_FUNNEL === "true";
const path = env.SIDECAR_SERVE_PATH || "/";
const address = env.SIDECAR_SERVE_ADDRESS || "http://127.0.0.1";

const config = {
    TCP: {
        "443": { HTTPS: httpsEnabled },
    },
    Web: {
        "${TS_CERT_DOMAIN}:443": {
            Handlers: {
                [path]: { Proxy: `${address}:${port}` },
            },
        },
    },
    AllowFunnel: {
        "${TS_CERT_DOMAIN}:443": allowFunnel,
    },
};

fs.mkdirSync("/config", { recursive: true });
fs.writeFileSync("/config/serve.json", JSON.stringify(config, null, 2));

console.log("✅ Generated /config/serve.json");