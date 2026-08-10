# Inkpress Roadmap

## ASC state verified 2026-08-10
Live state from `asc versions list --app 6787759999`:

| Version | State | Created |
|---|---|---|
| 1.0.3 | `READY_FOR_SALE` | 2026-08-10 |
| 1.0.2 | `READY_FOR_SALE` | 2026-07-05 |

**v1.0.3 APPROVED and LIVE** (approved 2026-08-10, icon redesign + loading indicator + multi-feed screenshot). **v1.0.4 READY** (blank-article fix via WKWebView rendering, not submitted due to Guideline 5.6 freeze until 2026-08-18). No `MAC_OS` version row exists on the record.

## From App Store.pdf (imported 2026-07-28)
- [ ] Ship a macOS version of InkPress. **Re-scoped 2026-08-10 — this is real dev work, not an
  ASC toggle.** The repo has no `macos/` directory at all (only `ios/`, `web/`, `metadata/`,
  `signing/`), so there is no macOS target to build. A macOS platform row is *created by
  submitting a macOS build*; it is not a row you add first and fill in later. Correct order:
  scaffold a macOS target in xcodegen (`macos/project.yml`, same pattern as healstack/sparkjar)
  → archive → upload → the `MAC_OS` row appears on `6787759999`. Estimate this as a build task,
  not a five-minute ASC chore.

## CMS/CRM pivot (scoped 2026-08-02, big — needs backend, phase before building)
Goal: Inkpress stays an RSS reader AND becomes a WordPress/Ghost-style CMS+CRM client. Currently pure read-only (no accounts, no write backend) per its own CLAUDE.md — this is a real scope change, not a bolt-on.

Phased so each phase ships something real instead of one giant unshippable build:

- [ ] **Phase 1 — MISSING FROM THIS PLAN (noted 2026-08-04).** Phase 0 is decided (Supabase on the shared `spark` project; `inkpress_posts` + `inkpress_contacts` tables exist, RLS-enabled with no policies, service-role writes only) and the list jumps straight to Phase 2, which assumes accounts already work. Phase 1 is presumably that missing rung: single-user authenticated write access (Supabase Swift SDK, same pattern as litigate/epiphany) plus the RLS policies those two tables are still missing. Define it before starting Phase 2, or fold it into Phase 2 explicitly.
- [ ] **Phase 2 — CMS read+write MVP.** Compose/edit a post in-app, publish to the chosen backend (Phase 0). Draft/scheduled/published states like Ghost. Needs accounts (single-user auth is enough at first).
- [ ] **Phase 3 — CRM layer.** Contacts/subscribers list (name, email, notes, source), tied to the same backend. Newsletter-subscriber-as-CRM-contact is the natural Ghost-esque bridge, not a separate sales-pipeline CRM.
- [ ] **Phase 4 — polish.** Theming/pages (WordPress-style), tags/categories, search.

Note: this pulls Inkpress away from its current "general-purpose reader, no accounts, no user-authored content" rule in its own CLAUDE.md — update that file once Phase 0 is decided.

## Article rendering (2026-08-10)
- [ ] **Native SwiftUI article renderer (optional).** v1.0.4 renders post bodies in a
  `WKWebView` (`ios/Sources/Shared/Views/EntryDetailView.swift`) after the previous
  `NSAttributedString` HTML importer produced blank bodies — SwiftUI `Text` renders nothing
  for an `AttributedString` containing an `NSTextAttachment`, which is what the importer
  makes of the `<img>` opening every post. The web view works and is the right lazy answer.
  Only revisit if offline image caching or a reader mode is wanted; that needs a real
  HTML→blocks parser. Related: [[project_webview_wrapper_gaps]] — this is a deliberate
  web view for article bodies, not a whole-app WKWebView wrapper.
