// CORS proxy so the web reader can fetch feeds the browser would otherwise block.
// ponytail: no cache API, no allowlist — Cloudflare's own edge cache via cf.cacheTtl
// covers repeat loads, and the handler only ever proxies GET of an https URL.
export async function onRequestGet({ request }) {
  const target = new URL(request.url).searchParams.get("url");
  let u;
  try { u = new URL(target); } catch { return new Response("bad url", { status: 400 }); }
  if (u.protocol !== "https:") return new Response("https only", { status: 400 });

  const upstream = await fetch(u.toString(), {
    headers: { "user-agent": "Inkpress/1.0 (+https://inkpress.heyitsmejosh.com)" },
    cf: { cacheTtl: 300, cacheEverything: true },
  });
  return new Response(upstream.body, {
    status: upstream.status,
    headers: {
      "content-type": upstream.headers.get("content-type") || "application/xml",
      "access-control-allow-origin": "*",
      "cache-control": "public, max-age=300",
    },
  });
}
