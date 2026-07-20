# journal Roadmap

## From Icons.pdf / Asc.pdf (imported 2026-07-12)
- [x] ~~Inkpress 1.0.2 waiting for review — monitor only~~ — superseded, see Stashed section: actually REJECTED (verified via `asc status --app 6787759999` 2026-07-20).

## 2026-07-14 dump
- [x] Verify entry styling fix — confirmed in code: `fefd0fe`/`243aa5a` wrap HTML render in a system-font/spacing `<style>` block + strip baked-in colors for dark mode (`ios/Sources/Shared/Views/EntryDetailView.swift`). Already included in the currently-uploaded build 1.0.2 (202607071200, VALID).
- [x] Improve /journal skill prose — entries too spammy, want native English — already addressed: `~/.claude/skills/journal/SKILL.md` has a detailed "Voice" section (first-person, no changelog phrasing, banned words list, before/after examples).

## RSS reader feature — DONE IN CODE, NOT YET SHIPPED (was "Idea: Inkpress as RSS reader")
- [x] Multi-feed RSS/Atom reader (add/remove feeds, aggregated timeline) — implemented, commit `0ab2592` "Inkpress: multi-feed RSS reader".
- [ ] **Not yet built/uploaded/resubmitted** — `asc status --app 6787759999` (2026-07-20) still shows build 1.0.2/202607071200 (uploaded 2026-07-07, before the RSS-reader commit) as the latest, and submission `409ce5a3` still REJECTED/UNRESOLVED_ISSUES. Top-level `~/Documents/Code/CLAUDE.md` claiming "resubmitted 2026-07-19" is stale — correct it. Needs: new archive with the RSS-reader code, upload, resubmit addressing Guideline 4.2 (this feature is the intended fix).

## From Inkpress.pdf (imported 2026-07-19)
- [x] Entry-open styling glitch — same fix as above (`fefd0fe`/`243aa5a`), already in the reviewed build. Not a new bug.
- [x] Rename to Inkpress — verified complete: `CFBundleDisplayName` = "Inkpress" (`ios/Sources/iOS/Info.plist`), nav title = "Inkpress" (`EntryListView.swift:26`), real AppIcon PNG present (`AppIcon.appiconset/icon-1024.png`, 12K, not a placeholder).
- [ ] Add a splash screen — still missing (`UILaunchScreen` is an empty dict in Info.plist = default blank screen). Needs a design asset, not just code. BLOCKED: no source asset to work from.

## Stashed 2026-07-19
- [ ] Inkpress iOS 1.0.2 REJECTED — Guideline 4.2 Minimum Functionality (reviewer: app lacks sufficient content/features). **Update 2026-07-20: the fix (multi-feed RSS reader) already exists in code (see above) but was never built+uploaded+resubmitted** — do that next, it directly addresses the rejection reason. ALSO still needs availability set in dashboard (CLI 404s). Submission `409ce5a3`; can reply to thread in ASC.
