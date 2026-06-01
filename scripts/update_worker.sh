#!/data/data/com.termux/files/usr/bin/bash
# Actualiza el Cloudflare Worker con la URL del tunnel actual
PREFIX=/data/data/com.termux/files/usr
source /data/data/com.termux/files/home/nc_vars.env
PUBLIC_URL="${PUBLIC_URL:-https://nextcloud.tudominio.workers.dev}"
TUNNEL_URL=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' $PREFIX/var/log/cf_tunnel.log 2>/dev/null | tail -1)

if [ -z "$TUNNEL_URL" ]; then
  echo "Error: Tunnel URL no encontrada"
  exit 1
fi

echo "Tunel: $TUNNEL_URL"

cat > $PREFIX/var/log/worker.js << EOF
const TUNNEL = "${TUNNEL_URL}";
const PUBLIC = "${PUBLIC_URL}";
export default {
  async fetch(req) {
    const url = new URL(req.url);
    const target = TUNNEL + url.pathname + url.search;
    const headers = new Headers(req.headers);
    headers.set("X-Forwarded-Proto", "https");
    headers.set("X-Forwarded-Host", new URL(PUBLIC).host);
    headers.delete("cf-connecting-ip");
    const isBodyless = req.method === "GET" || req.method === "HEAD";
    let res;
    try { res = await fetch(target, { method: req.method, headers, body: isBodyless ? undefined : req.body, redirect: "manual" }); }
    catch (e) { return new Response("Servidor no disponible: " + e.message, { status: 503 }); }
    const resHeaders = new Headers(res.headers);
    if (resHeaders.has("location")) { resHeaders.set("location", resHeaders.get("location").replace(/https?:\/\/[a-z0-9-]*\.trycloudflare\.com/, PUBLIC)); }
    resHeaders.set("X-Content-Type-Options", "nosniff");
    resHeaders.set("X-Frame-Options", "SAMEORIGIN");
    return new Response(res.body, { status: res.status, statusText: res.statusText, headers: resHeaders });
  }
};
EOF

HTTP=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID:?Error: ACCOUNT_ID no definida en nc_vars.env}/workers/scripts/${WORKER_NAME:?Error: WORKER_NAME no definida}" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -F "metadata={\"main_module\":\"worker.js\",\"usage_model\":\"bundled\",\"compatibility_date\":\"2024-01-01\"};type=application/json" \
  -F "worker.js=@$PREFIX/var/log/worker.js;type=application/javascript+module")

echo "Worker update: HTTP $HTTP"
