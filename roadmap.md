# Inkpress Roadmap

## macOS + web (2026-08-28)
- **macOS 1.0.7 SUBMITTED 2026-08-28 — first ever Mac release.** Version
  `002bb992-bc3c-4866-8de8-a783a1b8bdaf`, build `202608282156`, submission
  `daacdad3-5c27-4ac0-861e-bbef348b8801`, WAITING_FOR_REVIEW. Shipped once thumbnails
  landed, so the listing is not a text-only list. iOS 1.0.6 was left untouched in review.
  The old 1.0.5 / 202608250940 Mac build predates the entry-card overflow fix and must
  never be submitted; it is superseded.
- `asc validate` CANNOT run on this app while an iOS review is open: the age-rating fetch
  dies on "multiple app infos found" (one WAITING_FOR_REVIEW, one READY_FOR_DISTRIBUTION)
  and validate has no `--app-info` flag. `asc metadata` does, so pass
  `--app-info 19c32d48-1d0b-4fa5-8c67-d5b1cf09e2be`. Readiness had to be checked by hand:
  build attached + VALID, encryption declared false, screenshot uploaded, metadata verified
  by re-pull. `asc review submit --dry-run` is the closest substitute.
- **`whatsNew` cannot be set on a first release for a platform** — App Store Connect
  rejects it with "Attribute 'whatsNew' cannot be edited at this time", and the whole
  localization PATCH fails atomically, so nothing else in the same apply lands either.
  Drop the field and re-apply.
- Web reader live at inkpress.heyitsmejosh.com/read (`web/read.html` + `functions/feed.js`
  CORS proxy). Feeds/subscriptions in localStorage, no accounts.
- Entry list rows show a thumbnail on iOS, macOS and web (2026-08-28). Priority is
  `<media:thumbnail>`/`<media:content>` then `<enclosure type="image/*">` then the first
  `<img>` in the body; protocol-relative and relative srcs resolve against the entry link,
  and non-http(s) srcs are refused. No image means no thumbnail and an unchanged row - most
  feeds carry none, so a reserved empty box would have indented the whole list for nothing.
  The Swift and JS extractors mirror each other deliberately; change both or neither.
- **Next:** macOS has still never shipped - no MAC_OS version record exists on 6787759999,
  only the four IOS ones. Ship it as a first release now that the list is not text-only:
  bump to 1.0.7, archive with raw `xcodebuild` + `asc builds upload --pkg` (`asc xcode
  export` is iOS-only), push metadata BEFORE submit, reshoot the 1280x800 Mac screenshot
  (`ios/.asc/screenshots/mac/01-list.png` predates thumbnails). Never submit the build
  already sitting in ASC (202608250940, Aug 25) - it predates the overflow fix.


## Landing Page — animated hero + screenshot fix, shipped 2026-08-27

Fixed two web/ bugs. Screenshots were rendering vertically stretched because the `img` height
attribute locked aspect ratio while CSS `max-width` constrained width; added `height: auto` to
restore proportions. Added animated hero matching Bookrank's style with drifting feed-headline
cards instead of book covers, readability scrim, and prefers-reduced-motion guard. Deployed to
Cloudflare Pages.

## 1.0.5 — newsline feed merge, `WAITING_FOR_REVIEW` 2026-08-25

Submitted 16:45 UTC. Build `202608250942`, version id `2d6c2b40-2dc8-4d7f-ad99-4ee610b0bbd0`,
submission `a26ac12d-8e2b-4468-ba96-9f2f53ee70ba`. `marketingUrl` set to heyitsmejosh.com in
the same window (it locks at READY_FOR_SALE), so Inkpress comes off the cross-repo
"still locked" list.

**Gotcha for next time:** `asc workflow run ship-ios` archived, exported and uploaded fine, then
failed its `publish` step on `submission-blocking localization fields are missing: en-US:
whatsNew`. Writing `metadata/version/<v>/en-US.json` is not enough — the workflow never pushes
it. Run `asc metadata push --app <id> --version <v> --platform IOS --dir ./metadata` *before*
the workflow. And do not just re-run `publish` to recover: the build is already uploaded, so it
dies on "bundle version must be higher". Recover with `asc review submit --app <id> --version
<v> --build-id <id> --confirm` against the build that already landed.

Inkpress no longer launches subscribed to one blog. `FeedStore.seedFeeds` now carries the 16
curated outlets from newsline (`~/Documents/Code/newsline/src/feeds.js`) alongside the Journal
feed, and Manage Feeds grew a **Suggested** section so a removed seed can be re-added. Only the
*list* crossed over — Inkpress still parses RSS/Atom itself, so there is no runtime dependency
on the newsline Worker, and newsline's bias scores were dropped (no bias bar here).

Closes the "Phase 3 merges: newsline → inkpress" item in the cross-repo roadmap, and settles
"Newsline: do NOT submit" — its value now lives inside a shipping app.

Fixed in the same version, and worth remembering: `FeedParser.parseDate` only understood
RFC822 zones written as an offset (`-0400`), not as a name (`EDT`, `GMT`). Unparsed dates fell
back to `Date()`, so an entire feed could pin itself to the top of a newest-first list forever
— invisible with one feed, glaring with seventeen. Now tries a named-zone format too and falls
back to `.distantPast`, so anything genuinely undated sinks instead of floating.

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

## 2026-08-23 — needs real test coverage
iOS 1.0.3 is Ready for Distribution and the App Store side is fine. The gap is testing, not review.
- [ ] Add tests over the core write/save/publish path; run them before the next version bump.

## Ingested 2026-08-24

- [ ] Optional follow-up: mint a Pages-scoped Cloudflare token, add it as the `CLOUDFLARE_API_TOKEN` repo secret, and restore the deploy step (it is preserved as a comment in `.github/workflows/deploy-web.yml`). Needs the Cloudflare dashboard — the wrangler OAuth token can't create API tokens.
- [ ] **Extend Inkpress from a text/RSS reader into podcasts.** From Notes 2026-08-24, confirmed
      the same day: this rides on Inkpress rather than becoming a separate app, since the feed
      plumbing already exists — a podcast feed is just RSS with `<enclosure>` audio. Use Apple's
      Podcasts app as the design reference. Needs: enclosure parsing, an audio player with
      background playback and lock-screen controls (`MPNowPlayingInfoCenter` / `AVAudioSession`),
      per-episode playback position, and downloads for offline. Note this widens Inkpress from a
      reading product into a listening one — worth a positioning check before it grows further.

## WebMCP + REST API rollout -- assessed and closed 2026-08-27

Not doing this here. `web/` is a 91-line App Store landing page with zero `<script>` tags. The real app is iOS. Nothing for a browser agent to drive.

A tool on a page like this would be `get_page_content`, which spends an
agent's context restating text it can already read. That is noise, not
coverage, and it makes the honest tools in the other repos harder to find.

Shipped instead in: epiphany, healstack, roost, curvely, wiretext, litigate,
cadence, sparkjar, lexly, talli, quotable, wordroot, newsline, nyc, notes,
bookrank, homeward.

## From Notes (imported 2026-08-27)
- [x] **1.0.6 SUBMITTED — `WAITING_FOR_REVIEW` 2026-08-28.** Entry-card overflow fix (`3265419`, 2026-08-27) was in `main` but in no shipped binary: live 1.0.5 was built from 202608250940 (Aug 25), which predates it. Shipped end to end on 2026-08-28 — version id `1311e558-86d8-40a1-8e4d-231522b344c4`, build `d2ea70b6-bf38-43d9-8d10-e731cb34c17c` (202608282023, VALID), submission `3afa9621-0f7d-4ad4-9223-a81d9d70c4ae`. `asc validate` returned 0 errors / 0 blocking.
  - What's New was rewritten before submitting: `asc versions create --copy-metadata-from 1.0.5` copies the *previous* release's notes verbatim, which would have shipped 1.0.5's newsroom text on a bugfix release. Pull-plan-apply showed 1 update / 0 deletes, and the change was re-pulled to confirm it landed live.
  - **The old "1.0.5 is WAITING_FOR_REVIEW" premise was stale.** Re-probed 2026-08-28: iOS 1.0.5 is READY_FOR_SALE (as are 1.0.3 and 1.0.2). There was never a submission to wait behind.
  - **Submitted despite the open 4.3(a) wave** (see the macOS note at the top of this file, which still holds the Mac build back for that reason). Inkpress iOS was not one of the seven apps hit; this was an explicit call, not an oversight.
  - Note: `MARKETING_VERSION` lives in `settings.base`, so **Inkpress-macOS inherits 1.0.6 too** and now reads one version ahead of whatever Mac build is live. Cosmetic until a macOS archive is cut — don't ship macOS just to close the gap (same call as voxprint's 1.3.7).
