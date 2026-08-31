// The proxy used to return any https URL with `access-control-allow-origin: *`, which
// made it usable as an anonymizing proxy by any site. These pin the guards.
import { test } from "node:test";
import assert from "node:assert/strict";
import { onRequestGet } from "./functions/feed.js";

const call = (url) =>
  onRequestGet({ request: new Request(`https://inkpress.heyitsmejosh.com/feed?url=${encodeURIComponent(url)}`) });

test("rejects non-https", async () => {
  assert.equal((await call("http://example.com/rss")).status, 400);
});

test("rejects loopback and private hosts", async () => {
  for (const h of ["http://localhost/x", "https://127.0.0.1/x", "https://169.254.169.254/x", "https://10.1.2.3/x"]) {
    assert.equal((await call(h)).status, 400, h);
  }
});

test("rejects a malformed url", async () => {
  assert.equal((await call("not a url")).status, 400);
});

test("never returns a wildcard CORS origin", async () => {
  const bad = await call("http://example.com/rss");
  assert.equal(bad.headers.get("access-control-allow-origin"), "https://inkpress.heyitsmejosh.com");

  globalThis.fetch = async () => new Response("<rss/>", { headers: { "content-type": "application/xml" } });
  const ok = await call("https://example.com/rss");
  assert.equal(ok.headers.get("access-control-allow-origin"), "https://inkpress.heyitsmejosh.com");
});

test("refuses a feed larger than the cap", async () => {
  globalThis.fetch = async () =>
    new Response("x", { headers: { "content-length": String(50 * 1024 * 1024) } });
  assert.equal((await call("https://example.com/big")).status, 413);
});
