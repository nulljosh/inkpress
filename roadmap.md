# Inkpress Roadmap

## From App Store.pdf (imported 2026-07-28)
- [ ] Ship a macOS version of InkPress — needs a macOS platform/availability row added to the ASC record first (currently iOS 1.0.2 Ready for Distribution only, no macOS row). Merged with the duplicate entry that tracked the ASC half separately.

## CMS/CRM pivot (scoped 2026-08-02, big — needs backend, phase before building)
Goal: Inkpress stays an RSS reader AND becomes a WordPress/Ghost-style CMS+CRM client. Currently pure read-only (no accounts, no write backend) per its own CLAUDE.md — this is a real scope change, not a bolt-on.

Phased so each phase ships something real instead of one giant unshippable build:

- [ ] **Phase 1 — MISSING FROM THIS PLAN (noted 2026-08-04).** Phase 0 is decided (Supabase on the shared `spark` project; `inkpress_posts` + `inkpress_contacts` tables exist, RLS-enabled with no policies, service-role writes only) and the list jumps straight to Phase 2, which assumes accounts already work. Phase 1 is presumably that missing rung: single-user authenticated write access (Supabase Swift SDK, same pattern as litigate/epiphany) plus the RLS policies those two tables are still missing. Define it before starting Phase 2, or fold it into Phase 2 explicitly.
- [ ] **Phase 2 — CMS read+write MVP.** Compose/edit a post in-app, publish to the chosen backend (Phase 0). Draft/scheduled/published states like Ghost. Needs accounts (single-user auth is enough at first).
- [ ] **Phase 3 — CRM layer.** Contacts/subscribers list (name, email, notes, source), tied to the same backend. Newsletter-subscriber-as-CRM-contact is the natural Ghost-esque bridge, not a separate sales-pipeline CRM.
- [ ] **Phase 4 — polish.** Theming/pages (WordPress-style), tags/categories, search.

Note: this pulls Inkpress away from its current "general-purpose reader, no accounts, no user-authored content" rule in its own CLAUDE.md — update that file once Phase 0 is decided.
