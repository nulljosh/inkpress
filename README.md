<img src="icon.svg" width="80">

# Journal

![version](https://img.shields.io/badge/version-v2.2.0-blue) ![license](https://img.shields.io/badge/license-MIT-green) [![GitHub](https://img.shields.io/badge/GitHub-nulljosh%2Fjournal-black?logo=github)](https://github.com/nulljosh/journal)

Personal Jekyll blog.
Live at [journal.heyitsmejosh.com](https://journal.heyitsmejosh.com).

## Features
- Local Jekyll dev server via `bundle exec jekyll serve` at `http://localhost:4000/`.
- Posts live in `_posts/` named `YYYY-MM-DD-title.md` with front matter template and guidance to write like a normal person with no jargon pileup.
- `./scripts/ship.sh` is the publish path that blocks duplicate post dates, checks entries read like natural English, does a clean Jekyll build, previews today's homepage entry, pushes `main`, and force-pushes `gh-pages`.

## Run
```bash
bundle install
bundle exec jekyll serve
./scripts/ship.sh
```

## Roadmap
- [ ] Add a drafts workflow that previews unpublished posts without shipping.
- [ ] Add automatic image optimization for post assets.

## Changelog
v2.2.0
- GitHub Actions auto-build pipeline. Pushes to `main` trigger a clean build and deploy to `gh-pages` automatically.
- ship.sh simplified -- removed redundant steps handled by CI.
- Fixed light-mode `.dim` CSS in Apr 26, May 1, May 8 SVG headers (was `rgba(255,255,255,0.25)`, now `rgba(0,0,0,0.25)`).

v2.1.0
- Weekly SVG headers switched to monochrome palette with `prefers-color-scheme` theming to match the site CSS.
- Post URL note: slug derives from filename, not title. Name files `YYYY-MM-DD-slug.md` with the slug you want in the URL.

v2.0.0
- Documented local Jekyll serve workflow and localhost preview.
- Defined post naming, front matter, and writing guidance for entries.
- Added a ship script that validates posts, builds cleanly, previews today, and publishes to `main` and `gh-pages`.

## License
MIT 2026 Joshua Trommel
