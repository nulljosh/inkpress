# Inkpress Roadmap

## ASC state verified 2026-08-10
Live state from `asc versions list --app 6787759999`:

| Version | State | Created |
|---|---|---|
| 1.0.3 | `READY_FOR_SALE` | 2026-08-10 |
| 1.0.2 | `READY_FOR_SALE` | 2026-07-05 |

**v1.0.3 APPROVED and LIVE** (approved 2026-08-10, icon redesign + loading indicator + multi-feed screenshot). **v1.0.4 READY** (blank-article fix via WKWebView rendering, not submitted; the 5.6 freeze lifted 2026-08-18 but no 1.0.4 version row or build exists yet — needs archive + upload). No `MAC_OS` version row exists on the record.

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

- [ ] **Phase 1 — single-user authenticated write access. DEFINED 2026-08-13** (was "MISSING FROM THIS PLAN", noted 2026-08-04). Live DB state verified against the shared `spark` project (`tjsxsqlxjmanwvmywwvw`) on 2026-08-13:
  - `inkpress_posts` (`id`, `title`, `body_html`, `status` default `'draft'`, `created_at`, `updated_at`, `published_at`) and `inkpress_contacts` (`id`, `email`, `name`, `source`, `created_at`) both exist, RLS **enabled**, **0 policies**, **0 rows**.
  - RLS-on-with-no-policies means deny-all for `anon` and `authenticated`; only `service_role` (which bypasses RLS) can touch them today. Safe, but no client can read or write.
  - **The blocking gap nobody had named: neither table has a `user_id` column.** The "missing RLS policies" cannot be written as-is — there is nothing for `auth.uid()` to match against. This must be fixed *first*; it is the actual first step of Phase 1, not a detail of Phase 2.

  Steps, in order:
  1. **Migration** — add `user_id uuid not null references auth.users(id) default auth.uid()` to both tables. Both are empty, so no backfill and no nullable-then-tighten dance.
  2. **Policies** — one `for all using (user_id = auth.uid()) with check (user_id = auth.uid())` per table. This matches the established content-table pattern on this same DB (`brief_data`, `brief_documents`, `brief_checklist`). Do *not* copy the hardcoded-owner shortcut used by `brief_config`/`family_config` (`auth.uid() = '7453f262-…'::uuid`) — that is a config-table pattern and would need a rewrite the moment a second author exists.
  3. **Swift client** — add the Supabase Swift SDK and a sign-in screen, same pattern as litigate/epiphany. `auth.users` already has 8 rows on this shared project, so the account exists; this is wiring, not user creation.
  4. **Verify** — signed-in insert succeeds, signed-out insert is refused by RLS. That second half is the test that actually proves the policies work.

  Constraint: auth config (`site_url`, `uri_allow_list`) is **project-wide** on the shared `spark` DB and is also serving sparkjar/litigate/lexly. Diff before PATCHing; never blind-overwrite.

  Two schema gaps to settle here or explicitly defer to Phase 2: `status` has no CHECK constraint (nothing enforces draft/scheduled/published), and there is no `scheduled_at` column, so the "scheduled" state has nowhere to store its publish time.
- [ ] **Phase 2 — CMS read+write MVP.** Compose/edit a post in-app, publish to the chosen backend (Phase 0). Draft/scheduled/published states like Ghost. Needs accounts (single-user auth is enough at first).
- [ ] **Phase 3 — CRM layer.** Contacts/subscribers list (name, email, notes, source), tied to the same backend. Newsletter-subscriber-as-CRM-contact is the natural Ghost-esque bridge, not a separate sales-pipeline CRM.
- [ ] **Phase 4 — polish.** Theming/pages (WordPress-style), tags/categories, search.

Note: this pulls Inkpress away from its current "general-purpose reader, no accounts, no user-authored content" rule in its own CLAUDE.md — update that file once Phase 0 is decided.

### Article rendering (2026-08-10)
- **Native SwiftUI article renderer (optional).** Reclassified 2026-08-13: this is conditional on a
  future want, not a pending action — the current web view is the correct answer until one of the
  triggers below actually appears. v1.0.4 renders post bodies in a
  `WKWebView` (`ios/Sources/Shared/Views/EntryDetailView.swift`) after the previous
  `NSAttributedString` HTML importer produced blank bodies — SwiftUI `Text` renders nothing
  for an `AttributedString` containing an `NSTextAttachment`, which is what the importer
  makes of the `<img>` opening every post. The web view works and is the right lazy answer.
  Only revisit if offline image caching or a reader mode is wanted; that needs a real
  HTML→blocks parser. Related: [[project_webview_wrapper_gaps]] — this is a deliberate
  web view for article bodies, not a whole-app WKWebView wrapper.

## Ingested 2026-08-22
- [ ] Audit the journal repo for sensitive/personal data and clean it up. From Notes: "Clean up any sensitive data, or anything personal. All info should remain about code, not personal relationships etc." Applies to the journal content repo and anything already deployed.

## Landing page (2026-08-23)
Pages exist and are pushed (`web/`: `index.html`, `privacy.html`, `support.html`).
Everything below is account setup that needs Cloudflare and GitHub credentials — all
of it is doable from a phone browser, no terminal required.

- [ ] **Create the Cloudflare Pages project.** dash.cloudflare.com > Workers & Pages >
  Create > Pages > Connect to Git > `nulljosh/inkpress`. Production branch `main`,
  framework preset None, build command empty, output directory `web`. Project name must
  be `inkpress` to match `wrangler.toml` and the deploy workflow.
- [ ] **Attach the domain.** Same project > Custom domains > `inkpress.heyitsmejosh.com`.
  If `heyitsmejosh.com` is on Cloudflare DNS the record is added for you; if it is
  hosted elsewhere, add the CNAME Cloudflare shows you at the current DNS provider.
- [ ] **Add the two repo secrets.** github.com/nulljosh/inkpress > Settings > Secrets and
  variables > Actions: `CLOUDFLARE_API_TOKEN` (My Profile > API Tokens > Create, template
  "Edit Cloudflare Workers", or a custom token with Account > Cloudflare Pages > Edit) and
  `CLOUDFLARE_ACCOUNT_ID` (right-hand sidebar of any Cloudflare dashboard page).
  Only needed for the GitHub Actions path — if the Git integration above is connected,
  Cloudflare builds on its own and the workflow is belt-and-braces.
- [ ] **Confirm both pages load** at `/privacy.html` and `/support.html` before touching
  App Store Connect.
- [ ] Point App Store Connect at the real pages once `inkpress.heyitsmejosh.com` is
  serving. `metadata/app-info/en-US.json` has `privacyPolicyUrl` and
  `metadata/version/1.0.3/en-US.json` has `supportUrl`, both set to
  `https://journal.heyitsmejosh.com` — the Jekyll blog homepage, which is neither a
  privacy policy nor a support page. Should become
  `https://inkpress.heyitsmejosh.com/privacy.html` and `.../support.html`. Left
  unchanged for now because pointing Apple at URLs that do not resolve yet is worse
  than the current wrong-but-live URL. Order: deploy Pages, confirm both pages load,
  then edit the metadata and sync with `asc`.
- [ ] Add the landing page to the portfolio so it links there rather than straight to
  the App Store listing.

## 2026-08-23 — needs real test coverage
iOS 1.0.3 is Ready for Distribution and the App Store side is fine. The gap is testing, not review.
- [ ] Add tests over the core write/save/publish path; run them before the next version bump.

## Ingested 2026-08-24

- [ ] **GitHub Actions "Deploy landing page" is failing on `main`** (Notes 2026-08-24). Run #1, commit `1a60039` ("web: add privacy and support pages, fix landing page claims"), triggered via pull request by nulljosh. All jobs failed; the `deploy` job failed after 19s with 3 annotations. Pull the run log with `gh run view` and fix.
