# Journal
v2.3.0

## Rules
- Project is a personal Jekyll blog.
- URL slug comes from the filename, not the `title:` front matter. Filename format: `YYYY-MM-DD-slug.md` — the slug portion is what appears in the URL (e.g., `2026-04-13-week.md` ships at `/2026/04/13/week/`).
- Journal shares the portfolio's design tokens (`heyitsmejosh.com/tokens.css`, linked in `_layouts/default.html` before `main.css`). The blue `--accent` is used for link/hover states. `--text-secondary`/`--text-tertiary`/`--subtle` map to the shared `--text2`/`--text3`/`--border2`. Body font stays Geist (not the portfolio's mono) for reading comfort. SVG headers should use `var(--text)`/`var(--border)` with `prefers-color-scheme` media queries so they follow the same palette.
- Live site is `journal.heyitsmejosh.com`.
- Posts live in `_posts/`.
- `./scripts/deploy.sh` is the only publish path. It builds Jekyll locally and ships `_site` to the Vercel `journal` project via the Build Output API (`vercel deploy --prebuilt`), so Vercel never runs Ruby/bundler. There is no GitHub Pages / gh-pages flow and no remote build; a plain `git push` does not deploy.
- One post per month by default (changed 2026-07-04 from weekly; 13 weekly posts felt like changelog spam and got merged into 4 monthly entries covering Feb-Jul). Dated the last Friday or Sunday of the month covered. If multiple entries exist in the same month with no size reason, merge them into one and delete the extras.
- **Size/staleness exception (added 2026-07-21):** if the current month's post exceeds ~20KB, or today's date is more than ~10 days past its frontmatter `date:`, start a NEW post instead of appending further — even if it's the same calendar month. This is what "one post per month" is *for* (readable entries), not a hard rule to violate that goal. Split at a clean `##` day-heading boundary. (2026-07-03-june-july.md hit 157KB/18 days stale before this rule existed and had to be split retroactively into itself + 2026-07-21-ship-rename-repeat.md.)
- Filename date and front matter date must match.
- Write in natural English, not tool-name spam.
- Post titles must be short and punchy — under 6 words. No changelog-style summaries, no feature lists. Write a label, not a sentence.
- No em dashes.
- No filler phrases.
- No emojis.
- Fix errors immediately when they appear; do not leave obvious breakages for a later prompt.
- Break substantial work into smaller verifiable steps and keep the user informed.
- Never rewrite git history unless the user explicitly asks for it.
- Read docs or current local config before changing setup; back up high-risk config or scripts before editing them.
- After tool or agent upgrades, validate config, review changed defaults, re-auth integrations that depend on stored logins, and set new required config.
- When you learn something durable about how the user works or what they want, write it down in `CLAUDE.md` immediately.

Post front matter template:
```markdown
---
layout: post
title: "Title"
date: 2026-03-11 12:00:00 -0800
categories: journal daily
---
```

## Run
```bash
cd ~/Documents/Code/journal
bundle install
bundle exec jekyll serve   # local preview
./scripts/deploy.sh        # build locally + ship prebuilt static to Vercel
```

## /journal shortcut
Standalone repo: `nulljosh/journal` on GitHub, pushed from this directory (re-separated 2026-06-16, GitHub push completed 2026-06-18).
`/journal` (skill at `~/.claude/skills/journal.md`) creates or bumps the current week's entry, then builds and deploys:
```bash
/journal              # create/update this week's entry (interactive)
/journal <date>       # create entry for specific date (YYYY-MM-DD)
/journal push         # ./scripts/deploy.sh (build + ship to Vercel)
/journal open         # open current week's entry in browser
```

## Key Files
- `_posts/` - Published entries, one per date, with front matter.
- `scripts/deploy.sh` - Only publish path; builds Jekyll locally and deploys `_site` to Vercel with `--prebuilt`.
- `_config.yml` - Jekyll site configuration.
- `index.html` - Site entry point.

## iOS app — next steps (2026-07-07)
Fixed EntryDetailView.swift: HTML entry content was rendering unstyled (12pt Times, no spacing) because NSAttributedString's HTML importer has no default CSS. Now wraps content in a `<style>` block forcing system font + heading sizes + paragraph spacing before parsing. Committed + pushed to GitHub. Build 1.0.2 (202607071200) archived, exported, uploaded — VALID on ASC/TestFlight. Auto-submit for App Store review failed: 1.0.1 is still WAITING_FOR_REVIEW, Apple blocks a new version submit while one's pending. Next: either wait for 1.0.1 to clear review, or cancel it and submit 1.0.2 instead (has the actual styling fix).

## iOS app — next steps (2026-07-06)
Dark-mode fix (invisible entry content) committed 243aa5a but NOT in the build under review (1.0.1 b2, WAITING_FOR_REVIEW). Next: cancel submission, then `asc workflow run ship-ios VERSION:1.0.1` (or 1.0.2) to ship b3 with the fix.

## iOS app — next steps (2026-07-05)
IPA ready at `ios/.asc/artifacts/Journal.ipa` (1.0.0 b1). Bundle ID registered.
Done 2026-07-05: submitted for App Review (submission e88f9bcf, build 1.0 b1). Availability initialized on submit; check review status with `asc status --app 6787759999`.
2. Then: `asc builds upload --app <NEW_APP_ID> --ipa ios/.asc/artifacts/Journal.ipa --wait`
