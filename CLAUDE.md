# Journal
v2.2.0

## Rules
- Project is a personal Jekyll blog.
- URL slug comes from the filename, not the `title:` front matter. Filename format: `YYYY-MM-DD-slug.md` — the slug portion is what appears in the URL (e.g., `2026-04-13-week.md` ships at `/2026/04/13/week/`).
- SVG headers must match the site CSS. Use monochrome `#000`/`#e8e8e8` with `prefers-color-scheme` media queries embedded in the SVG `<style>` block. No green, amber, or other accents — the dark editorial palette is for landing pages, not this journal.
- Live site is `journal.heyitsmejosh.com`.
- Posts live in `_posts/`.
- `./scripts/deploy.sh` is the only publish path. It builds Jekyll locally and ships `_site` to the Vercel `journal` project via the Build Output API (`vercel deploy --prebuilt`), so Vercel never runs Ruby/bundler. There is no GitHub Pages / gh-pages flow and no remote build; a plain `git push` does not deploy.
- One post per week. Never create more than one entry in the same calendar week. The weekly post must be dated either Friday or Sunday. If multiple entries exist in the same week, merge them into a single Friday or Sunday entry and delete the extras.
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
cd ~/Documents/Code/apps/journal
bundle install
bundle exec jekyll serve   # local preview
./scripts/deploy.sh        # build locally + ship prebuilt static to Vercel
```

## Key Files
- `_posts/` - Published entries, one per date, with front matter.
- `scripts/deploy.sh` - Only publish path; builds Jekyll locally and deploys `_site` to Vercel with `--prebuilt`.
- `_config.yml` - Jekyll site configuration.
- `index.html` - Site entry point.
