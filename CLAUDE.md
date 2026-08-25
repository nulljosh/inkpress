# Inkpress
v1.0.5 WAITING_FOR_REVIEW (build 202608250942, submitted 2026-08-25). v1.0.3 is live.

## Open
- Nothing blocking on v1.0.5 — awaiting Apple review. It seeds 16 curated news feeds on first launch (from newsline's list) instead of one blog, and fixes a date-parser bug where feeds stamping RFC822 zones by name (EDT, GMT) sorted to the top forever. See `roadmap.md`.

## Ship gotchas (learned 2026-08-09)
- The App Store icon must be a **fully opaque square** — `AppIcon.appiconset/icon-1024.png` shipped with transparent rounded corners once and the upload failed with **90717**. iOS applies the corner mask itself. Flatten with `magick icon.png -background '#161412' -alpha remove -alpha off -type TrueColor PNG24:icon.png`.
- `ITSAppUsesNonExemptEncryption=false` now lives in `Sources/iOS/Info.plist`; without it every upload needs a manual `asc builds update --uses-non-exempt-encryption=false`.
- The 1284x2778 screenshot is `APP_IPHONE_65`, not `IPHONE_67` — `asc screenshots upload` rejects the wrong display type.
- `asc review submit` can falsely report the prepared submission "does not contain target version". Fall back to `asc review submissions-submit --id <submission-id> --confirm`.
- The xcodegen scheme is `Journal-iOS` (not `Inkpress`) — the bundle id `com.nulljosh.journal` and project name are Apple-locked from the pre-rename days.

## Rules
- Multi-feed RSS/Atom reader, iOS only. Split from the `journal` repo 2026-07-21 — that repo now holds only the Jekyll blog. No shared code between the two; `FeedStore.seedFeeds` in `ios/Sources/Shared/Models/Feed.swift` subscribes to the blog's `feed.xml` on first launch as one regular feed among the curated news seeds, same as anything a user adds themselves.
- Renamed from "Journal" to "Inkpress" 2026-07-06 to avoid a name collision with Apple's own Journal app. ASC app id 6787759999, GitHub `nulljosh/inkpress`.
- **Superseded 2026-08-02**: the "no accounts, no writing feature" rule below is being phased out — Inkpress is pivoting to also be a CMS/CRM client (WordPress/Ghost-inspired), staying an RSS reader too. See CMS/CRM Pivot roadmap in `roadmap.md`. Old rule, now historical: no accounts, no journaling/writing feature, no user-authored content — it only reads feeds.
- Build via xcodegen (`project.yml`), no checked-in `.xcodeproj` diffs expected beyond what xcodegen regenerates.
- No emojis, no monospace UI chrome (see house style).

## Backend (CMS/CRM pivot, Phase 0 decided 2026-08-02)
- Supabase, reusing the shared `spark` project (`tjsxsqlxjmanwvmywwvw`) per house convention (free tier capped at 2 projects) — not git-commit-to-Jekyll, because Phase 3 (subscriber contacts) needs real queryable tables.
- Tables: `inkpress_posts` (title, body_html, status draft/published, timestamps), `inkpress_contacts` (email unique, name, source, created_at). Both RLS-enabled with no policies yet — service-role-only writes until Phase 2 adds authenticated single-user write (Supabase Swift SDK pattern, same as litigate/epiphany).
- No Swift code or UI against these tables yet — that's Phase 2+.

## Run
```bash
cd ios
xcodegen generate
xcodebuild -project journal.xcodeproj -scheme Journal-iOS -destination 'generic/platform=iOS Simulator' build
```

## Key Files
- `ios/Sources/Shared/Models/Feed.swift` — `Feed`, `FeedStore` (persisted subscriptions, `seedFeeds` first-launch list)
- `ios/Sources/Shared/Views/ManageFeedsView.swift` — add/remove feeds UI
- `ios/Sources/Shared/Services/JournalFeedService.swift` — feed fetch/parse (RSS + Atom)
- `ios/Sources/Shared/Views/EntryDetailView.swift` — entry render, wraps HTML content in a forced `<style>` block since `NSAttributedString`'s HTML importer has no default CSS

## Related
[[journal]] — the Jekyll blog this repo used to share a folder with. Inkpress subscribes to journal.heyitsmejosh.com/feed.xml by default.
