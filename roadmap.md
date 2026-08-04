# Inkpress Roadmap

## From App Store.pdf (imported 2026-07-28)
- [ ] Ship a macOS version of InkPress.

## From App Store.pdf (imported 2026-07-29)
- [ ] Still needs a macOS availability/platform added — ASC shows iOS 1.0.2 Ready for Distribution only, no macOS row at all.

## CMS/CRM pivot (scoped 2026-08-02, big — needs backend, phase before building)
Goal: Inkpress stays an RSS reader AND becomes a WordPress/Ghost-style CMS+CRM client. Currently pure read-only (no accounts, no write backend) per its own CLAUDE.md — this is a real scope change, not a bolt-on.

Phased so each phase ships something real instead of one giant unshippable build:

- [x] **Phase 0 — backend decision.** Decided 2026-08-02: Supabase, shared `spark` project (`tjsxsqlxjmanwvmywwvw`). `inkpress_posts` + `inkpress_contacts` tables created, RLS enabled, no policies yet (service-role-only). See `inkpress/CLAUDE.md` Backend section.
- [x] **Phase 1 — svbtle-style upvote.** Shipped 2026-08-02: `UpvoteButton.swift`, tap-toggle circle→circle.fill, UserDefaults-backed, wired into `EntryListView` row.
- [ ] **Phase 2 — CMS read+write MVP.** Compose/edit a post in-app, publish to the chosen backend (Phase 0). Draft/scheduled/published states like Ghost. Needs accounts (single-user auth is enough at first).
- [ ] **Phase 3 — CRM layer.** Contacts/subscribers list (name, email, notes, source), tied to the same backend. Newsletter-subscriber-as-CRM-contact is the natural Ghost-esque bridge, not a separate sales-pipeline CRM.
- [ ] **Phase 4 — polish.** Theming/pages (WordPress-style), tags/categories, search.

Note: this pulls Inkpress away from its current "general-purpose reader, no accounts, no user-authored content" rule in its own CLAUDE.md — update that file once Phase 0 is decided.

## TestFlight signing defect (found 2026-08-03)

- [x] **FIXED 2026-08-04.** Added `ios/Journal.entitlements` (`application-identifier` = `$(AppIdentifierPrefix)$(CFBundleIdentifier)`) wired via `CODE_SIGN_ENTITLEMENTS` in `ios/project.yml`, mirroring the Uprighty pattern. Verified on a real Release archive: `codesign -d --entitlements` now shows `application-identifier => QMM486NPYC.com.nulljosh.journal`. Note a simulator build can't verify this (no profile → empty entitlements); archive against `generic/platform=iOS`. Original report below.
  Original report: iOS builds were TestFlight-ineligible (ITMS-90886). This repo had **no `.entitlements` file and no `CODE_SIGN_ENTITLEMENTS`** anywhere, so the app signs without an `application-identifier` while the provisioning profile has one. Apple reports it as "not required to fix", which is why it went unnoticed — but the build cannot be distributed via TestFlight.
  Fix proven on Uprighty 2026-08-03 (commit `df346b8`): add `<Target>.entitlements` with `application-identifier` = `$(AppIdentifierPrefix)$(CFBundleIdentifier)`, wire via `CODE_SIGN_ENTITLEMENTS` in `project.yml`, hand-commit it (xcodegen silently drops keys).
  Verify: `codesign -d --entitlements :- <exported>.app` should show `application-identifier`, `beta-reports-active: true`, `get-task-allow: false`. An entitlement change invalidates the profile — refetch with `asc signing fetch`.
