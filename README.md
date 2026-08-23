<img src="icon.svg" width="80">

# Inkpress

![version](https://img.shields.io/badge/version-1.0.2-blue) ![license](https://img.shields.io/badge/license-MIT-green) [![GitHub](https://img.shields.io/badge/GitHub-nulljosh%2Finkpress-black?logo=github)](https://github.com/nulljosh/inkpress)

Multi-feed RSS/Atom reader for iOS. Add any feed, get an aggregated timeline
across all of them.

Live on the [App Store](https://apps.apple.com/app/id6787759999) — landing page at [inkpress.heyitsmejosh.com](https://inkpress.heyitsmejosh.com)

Split from the `journal` repo 2026-07-21 — this repo now holds only the iOS
app. The blog that used to share this folder lives at
[github.com/nulljosh/journal](https://github.com/nulljosh/journal); Inkpress
subscribes to its `feed.xml` by default, same as any other feed, with no code
coupling between the two.

## Features
- Add/remove any RSS or Atom feed
- Aggregated, reverse-chronological timeline across all subscriptions
- Per-feed management (`ManageFeedsView`)
- Seeded with one feed on first launch so the app isn't empty (`FeedStore.defaultFeed`), fully removable

## Run
```bash
cd ios
xcodegen generate
xcodebuild -scheme Inkpress -destination 'generic/platform=iOS Simulator' build
```

## Landing page

Static site in `web/` — `index.html`, plus `privacy.html` and `support.html`
(intended as the App Store privacy-policy and support URLs — App Store
Connect still points both at the blog, see `roadmap.md`). No build step; the
three pages share `web/style.css`.

Preview locally:

```bash
cd web && python3 -m http.server 8000
```

Deploys to Cloudflare Pages from `main` whenever `web/` changes, via
`.github/workflows/deploy-web.yml`. The workflow runs `scripts/check-links.py`
first so a broken internal link fails the build instead of shipping. Needs
repo secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`; the custom
domain is attached once in the Cloudflare dashboard.

## Roadmap
- [ ] Splash screen (needs a design asset, not just code)
- [ ] Cross-device sync of feed subscriptions (would need accounts — not started, no current need)

## License
MIT 2026 Joshua Trommel

## Whitepaper

[Technical whitepaper](WHITEPAPER.md)
