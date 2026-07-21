# Inkpress
v1.0.2

## Rules
- Multi-feed RSS/Atom reader, iOS only. Split from the `journal` repo 2026-07-21 — that repo now holds only the Jekyll blog. No shared code between the two; `FeedStore.defaultFeed` in `ios/Sources/Shared/Models/Feed.swift` subscribes to the blog's `feed.xml` on first launch as a regular feed, same as anything a user adds themselves.
- Renamed from "Journal" to "Inkpress" 2026-07-06 to avoid a name collision with Apple's own Journal app. ASC app id 6787759999, GitHub `nulljosh/inkpress`.
- General-purpose product, not personal-data-specific: no accounts, no journaling/writing feature, no user-authored content — it only reads feeds. If a writing/logging feature is ever wanted, that's a distinct feature decision (needs accounts + a write backend) — don't bolt it on without reconsidering scope.
- Build via xcodegen (`project.yml`), no checked-in `.xcodeproj` diffs expected beyond what xcodegen regenerates.
- No emojis, no monospace UI chrome (see house style).

## Run
```bash
cd ios
xcodegen generate
xcodebuild -scheme Inkpress -destination 'generic/platform=iOS Simulator' build
```

## Key Files
- `ios/Sources/Shared/Models/Feed.swift` — `Feed`, `FeedStore` (persisted subscriptions, default seed feed)
- `ios/Sources/Shared/Views/ManageFeedsView.swift` — add/remove feeds UI
- `ios/Sources/Shared/Services/JournalFeedService.swift` — feed fetch/parse (RSS + Atom)
- `ios/Sources/Shared/Views/EntryDetailView.swift` — entry render, wraps HTML content in a forced `<style>` block since `NSAttributedString`'s HTML importer has no default CSS

## Related
[[journal]] — the Jekyll blog this repo used to share a folder with. Inkpress subscribes to journal.heyitsmejosh.com/feed.xml by default.
