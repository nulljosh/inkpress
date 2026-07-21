# Inkpress Technical Whitepaper

**v1.0.2** | July 2026

Inkpress is a multi-feed RSS/Atom reader for iOS. Add any feed, get an
aggregated, reverse-chronological timeline across all of them. Split from
the `journal` repo (a personal Jekyll blog) on 2026-07-21 — the two are
unrelated products that only used to share a folder for naming-history
reasons.

## Content Model

Feeds are a simple persisted list (`FeedStore`, `Application Support/feeds.json`
on-device, no server sync). Seeded with one feed on first launch
(`journal.heyitsmejosh.com/feed.xml`, the author's own blog) purely so the
app isn't empty on first open — it's a regular subscription, fully
removable, with no special handling versus any other feed the user adds.

## Parsing

`JournalFeedService` fetches and parses both RSS and Atom formats. Entry
HTML content is wrapped in a forced `<style>` block before rendering, since
`NSAttributedString`'s HTML importer has no default CSS and would otherwise
render unstyled serif text with no spacing.

## Scope

No accounts, no user-authored content, no writing/logging feature — Inkpress
only reads feeds. Cross-device sync of subscriptions would need accounts;
not started, no current need.

## Security / Privacy

No backend, no user accounts, no data collection. Feed subscriptions are
stored locally on-device only.

## License

MIT 2026, Joshua Trommel
