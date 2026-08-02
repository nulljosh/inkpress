# Inkpress Roadmap

## From App Store.pdf (imported 2026-07-28)
- [ ] Ship a macOS version of InkPress.

## From App Store.pdf (imported 2026-07-29)
- [ ] Still needs a macOS availability/platform added — ASC shows iOS 1.0.2 Ready for Distribution only, no macOS row at all.

## CMS/CRM pivot (scoped 2026-08-02, big — needs backend, phase before building)
Goal: Inkpress stays an RSS reader AND becomes a WordPress/Ghost-style CMS+CRM client. Currently pure read-only (no accounts, no write backend) per its own CLAUDE.md — this is a real scope change, not a bolt-on.

Phased so each phase ships something real instead of one giant unshippable build:

- [ ] **Phase 0 — backend decision.** CMS write features need a write API + auth (currently none). Candidates: reuse `journal`'s Jekyll repo via a small write API (git commit per post), or a proper backend (Supabase, reusing the shared `spark` project per house convention) with posts/pages/subscribers tables. Ghost/WordPress both use a DB-backed API — recommend Supabase over git-commit-as-CMS for CRM-style querying (contacts, subscriber lists) later.
- [ ] **Phase 1 — svbtle-style upvote.** Hover/tap empty circle fills to solid on `EntryDetailView`/`EntryListView`. Self-contained UI, no backend, ship first. (Ref: svbtle.com interaction Joshua wants copied.)
- [ ] **Phase 2 — CMS read+write MVP.** Compose/edit a post in-app, publish to the chosen backend (Phase 0). Draft/scheduled/published states like Ghost. Needs accounts (single-user auth is enough at first).
- [ ] **Phase 3 — CRM layer.** Contacts/subscribers list (name, email, notes, source), tied to the same backend. Newsletter-subscriber-as-CRM-contact is the natural Ghost-esque bridge, not a separate sales-pipeline CRM.
- [ ] **Phase 4 — polish.** Theming/pages (WordPress-style), tags/categories, search.

Note: this pulls Inkpress away from its current "general-purpose reader, no accounts, no user-authored content" rule in its own CLAUDE.md — update that file once Phase 0 is decided.
