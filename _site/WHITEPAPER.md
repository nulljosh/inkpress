# Journal Technical Whitepaper

**v2.3.0** | July 2026

Journal is a personal Jekyll blog, one post per month, shipped as a prebuilt
static site rather than a server-rendered Ruby app. Live at
[journal.heyitsmejosh.com](https://journal.heyitsmejosh.com), with a companion
iOS app (Inkpress).

## Build and Deploy Path

The only publish path is `./scripts/deploy.sh`: it runs Jekyll locally, then
ships the resulting `_site` directory to the Vercel `journal` project via the
Build Output API (`vercel deploy --prebuilt`). Vercel itself never runs Ruby
or Bundler — it only serves the static output handed to it. A plain
`git push` does not deploy; the script is required.

## Content Model

Posts live in `_posts/` as `YYYY-MM-DD-slug.md`. The URL is derived from the
filename's slug portion, not the `title:` front matter — `2026-04-13-week.md`
ships at `/2026/04/13/week/` regardless of what the post's title says.
Filename date and front-matter `date:` must match. Cadence is one post per
calendar month (changed from weekly in 2026-07 — weekly posts read as
changelog spam); if multiple posts land in the same month they get merged
into one and the extras deleted.

## Design

Shares the portfolio's design tokens (`heyitsmejosh.com/tokens.css`) for
color/spacing, keeping the blue `--accent` and text-hierarchy variables in
sync across sites, but keeps body text in Geist rather than the portfolio's
monospace, for reading comfort at length.

## Companion App

| Platform | Framework | Notes |
|----------|-----------|-------|
| iOS | — | Inkpress, reads the same published content |

## Security / Privacy

Fully static output, no backend, no user accounts, no data collection.

## License

MIT 2026, Joshua Trommel
