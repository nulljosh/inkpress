# journal Roadmap

## From Icons.pdf / Asc.pdf (imported 2026-07-12)
- [x] ~~Inkpress 1.0.2 waiting for review — monitor only~~ — superseded, see Stashed section: actually REJECTED (verified via `asc status --app 6787759999` 2026-07-20).

## 2026-07-14 dump
- [x] Verify entry styling fix — confirmed in code: `fefd0fe`/`243aa5a` wrap HTML render in a system-font/spacing `<style>` block + strip baked-in colors for dark mode (`ios/Sources/Shared/Views/EntryDetailView.swift`). Already included in the currently-uploaded build 1.0.2 (202607071200, VALID).
- [x] Improve /journal skill prose — entries too spammy, want native English — already addressed: `~/.claude/skills/journal/SKILL.md` has a detailed "Voice" section (first-person, no changelog phrasing, banned words list, before/after examples).

## RSS reader feature — DONE IN CODE, NOT YET SHIPPED (was "Idea: Inkpress as RSS reader")
- [x] Multi-feed RSS/Atom reader (add/remove feeds, aggregated timeline) — implemented, commit `0ab2592` "Inkpress: multi-feed RSS reader".
- [x] **Shipped + submitted 2026-07-21**: build 202607211502 with the RSS-reader code. Found + fixed a version mismatch (project.yml said 1.0.1, ASC's existing version record was 1.0.2) — rebuilt as 1.0.2, re-uploaded. Also set pricing (free, US base) and availability (all 175 territories) via `asc pricing schedule create --free` / `asc pricing availability create` — both were entirely missing (app had never had pricing/availability configured, a blocker separate from the 4.2 rejection). Canceled the stale rejected submission, resubmitted. **1.0.2 is now WAITING_FOR_REVIEW.**

## From Inkpress.pdf (imported 2026-07-19)
- [x] Entry-open styling glitch — same fix as above (`fefd0fe`/`243aa5a`), already in the reviewed build. Not a new bug.
- [x] Rename to Inkpress — verified complete: `CFBundleDisplayName` = "Inkpress" (`ios/Sources/iOS/Info.plist`), nav title = "Inkpress" (`EntryListView.swift:26`), real AppIcon PNG present (`AppIcon.appiconset/icon-1024.png`, 12K, not a placeholder).
- [ ] Add a splash screen — still missing (`UILaunchScreen` is an empty dict in Info.plist = default blank screen). Needs a design asset, not just code. BLOCKED: no source asset to work from.

## Stashed 2026-07-19
- [x] Inkpress iOS 1.0.2 REJECTED — Guideline 4.2 Minimum Functionality. Duplicate of the item resolved above (line 12) on 2026-07-21: RSS-reader build resubmitted, pricing/availability set via CLI (the "dashboard/404" blocker was stale — `asc pricing schedule create --free` / `asc pricing availability create` worked directly). 1.0.2 confirmed WAITING_FOR_REVIEW as of 2026-07-21T22:27 via `asc review status --app 6787759999`. Nothing further to do but wait for Apple's review outcome.
