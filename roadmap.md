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
