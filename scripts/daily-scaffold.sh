#!/bin/bash
# daily-scaffold.sh -- nightly journal entry generator
# Scans all repos in ~/Documents/Code for today's git activity,
# generates a natural write-up and SVG via Claude (haiku), commits and pushes.
# Runs at 11pm via launchd (com.joshua.journal-daily).
# Can also run manually: ./daily-scaffold.sh [YYYY-MM-DD]

set -uo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$PATH"

DATE=${1:-$(date +%Y-%m-%d)}
CODE_DIR="$HOME/Documents/Code"
JOURNAL_DIR="$CODE_DIR/journal"
POST_FILE="$JOURNAL_DIR/_posts/${DATE}-entry.md"
SVG_FILE="$JOURNAL_DIR/assets/${DATE}-entry.svg"
LOG_DIR="$HOME/.cache/auto-journal"
mkdir -p "$LOG_DIR" "$JOURNAL_DIR/assets" "$JOURNAL_DIR/_posts"

echo "[journal-entry] Running for ${DATE}..."

# Skip if an entry already exists for this date (manual or prior run)
if ls "$JOURNAL_DIR/_posts/${DATE}-"*.md 2>/dev/null | grep -q .; then
    echo "[journal-entry] Entry already exists for ${DATE}. Skipping."
    exit 0
fi

# Gather commits from all repos
COMMIT_DATA=""
REPO_NAMES=""
while IFS= read -r -d '' gitdir; do
    repo_dir=$(dirname "$gitdir")
    name=$(basename "$repo_dir")
    [[ "$name" == "journal" ]] && continue
    cd "$repo_dir" || continue
    commits=$(git log --oneline --since="${DATE} 00:00:00" --until="${DATE} 23:59:59" --no-merges 2>/dev/null || true)
    if [ -n "$commits" ]; then
        stats=$(git log --stat --since="${DATE} 00:00:00" --until="${DATE} 23:59:59" --no-merges 2>/dev/null | tail -40)
        COMMIT_DATA="${COMMIT_DATA}
=== ${name} ===
${stats}
"
        REPO_NAMES="${REPO_NAMES}, ${name}"
    fi
done < <(find "$CODE_DIR" -maxdepth 3 -type d -name ".git" -not -path "*/node_modules/*" -print0 2>/dev/null)

REPO_NAMES="${REPO_NAMES#, }"

if [ -z "$REPO_NAMES" ]; then
    echo "[journal-entry] No commits found for ${DATE}. Skipping."
    exit 0
fi

echo "[journal-entry] Activity in: ${REPO_NAMES}"

CLAUDE_BIN=$(command -v claude 2>/dev/null || true)

if [ -z "$CLAUDE_BIN" ]; then
    echo "[journal-entry] claude CLI not found. Skipping."
    exit 1
fi

# Generate the post
POST_PROMPT="Write a daily journal entry for a software engineer's personal blog. Date: ${DATE}.

Commits from today:

${COMMIT_DATA}

Rules:
- Front matter: layout: post, title (short natural title, 3-6 words), date: ${DATE}
- After front matter: ![${DATE}](/assets/${DATE}-entry.svg)
- Write like a person, not a machine. Short sentences. First person.
- Plain English only. No jargon, no acronyms, no implementation details.
- Describe what changed and why it matters, not how it was built.
- No emojis. No em dashes. No filler. No bullet points.
- A few short paragraphs grouped by project. Use ## headers for each project.
- Skip auto-sync commits and trivial changes.
- Output ONLY the markdown file contents."

echo "[journal-entry] Generating post..."
POST_CONTENT=$(CLAUDECODE="" "$CLAUDE_BIN" -p --model haiku --bare --max-budget-usd 0.05 "$POST_PROMPT" 2>/dev/null || true)

if [ -z "$POST_CONTENT" ] || echo "$POST_CONTENT" | grep -qi "not logged in\|please run /login\|run /login"; then
    echo "[journal-entry] Claude auth error or empty output. Skipping."
    exit 1
fi

# Generate the SVG
SVG_PROMPT="Generate an SVG header image for a daily journal entry. Date: ${DATE}. Active repos: ${REPO_NAMES}.

Key commits:
${COMMIT_DATA}

SVG rules:
- viewBox 0 0 800 400, width 800 height 400
- Dark background #0c1a12
- Border box with rounded corners, stroke #3d9e6a at low opacity
- Header text in DM Sans or system-ui, color #e8e4da
- Subheader in #8a9e90
- Project names and short labels in monospace #3d9e6a
- Stats box on the right with #d4a843 monospace text
- Date at bottom in Fraunces serif, #e8e4da at 0.6 opacity
- Clean, minimal, no gradients
- Output ONLY the raw SVG markup. No code fences."

echo "[journal-entry] Generating SVG..."
SVG_CONTENT=$(CLAUDECODE="" "$CLAUDE_BIN" -p --model haiku --bare --max-budget-usd 0.03 "$SVG_PROMPT" 2>/dev/null || true)

# Write files
echo "$POST_CONTENT" > "$POST_FILE"
echo "[journal-entry] Post written: $POST_FILE"

if [ -n "$SVG_CONTENT" ]; then
    echo "$SVG_CONTENT" > "$SVG_FILE"
    echo "[journal-entry] SVG written: $SVG_FILE"
fi

# Commit and push
cd "$JOURNAL_DIR"
git add "_posts/${DATE}-entry.md"
[ -f "$SVG_FILE" ] && git add "assets/${DATE}-entry.svg"
git commit -m "journal: ${DATE} entry" 2>/dev/null || true
git push origin main 2>/dev/null || true

echo "[journal-entry] Done."
