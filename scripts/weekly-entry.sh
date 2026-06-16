#!/bin/bash
# weekly-entry.sh -- weekly journal entry generator
# Scans all repos in ~/Documents/Code for this week's git activity,
# generates a lean weekly write-up and SVG via Claude (haiku), commits and pushes.
# Runs every Friday at 11pm via launchd (com.joshua.journal-weekly).
# Can also run manually: ./weekly-entry.sh [YYYY-MM-DD for Friday]

set -uo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin:$PATH"

# Determine target Friday date
if [ "${1:-}" != "" ]; then
    FRIDAY="$1"
else
    FRIDAY=$(python3 -c "
from datetime import date, timedelta
today = date.today()
dow = today.weekday()  # 0=Mon, 6=Sun
days_to_fri = (4 - dow) % 7
print(today + timedelta(days=days_to_fri))
")
fi

MONDAY=$(python3 -c "
from datetime import date, timedelta
fri = date.fromisoformat('$FRIDAY')
print(fri - timedelta(days=4))
")

MONTH_DAY=$(python3 -c "
from datetime import date
d = date.fromisoformat('$MONDAY')
print(d.strftime('%B %-d'))
")

WINDOW_LABEL=$(python3 -c "
from datetime import date
mon = date.fromisoformat('$MONDAY')
fri = date.fromisoformat('$FRIDAY')
if mon.month == fri.month:
    print(mon.strftime('%b %-d') + ' -- ' + fri.strftime('%-d'))
else:
    print(mon.strftime('%b %-d') + ' -- ' + fri.strftime('%b %-d'))
")

CODE_DIR="$HOME/Documents/Code"
JOURNAL_DIR="$CODE_DIR/journal"
POST_FILE="$JOURNAL_DIR/_posts/${FRIDAY}-week.md"
SVG_FILE="$JOURNAL_DIR/assets/${FRIDAY}-week.svg"
LOG_DIR="$HOME/.cache/auto-journal"
mkdir -p "$LOG_DIR" "$JOURNAL_DIR/assets" "$JOURNAL_DIR/_posts"

echo "[weekly-entry] Week: ${MONDAY} -- ${FRIDAY}"

if [ -f "$POST_FILE" ]; then
    echo "[weekly-entry] Entry already exists: $POST_FILE. Skipping."
    exit 0
fi

# Gather commits from all repos for the week
COMMIT_DATA=""
REPO_NAMES=""
while IFS= read -r -d '' gitdir; do
    repo_dir=$(dirname "$gitdir")
    name=$(basename "$repo_dir")
    [[ "$name" == "journal" ]] && continue
    cd "$repo_dir" || continue
    commits=$(git log --oneline --since="${MONDAY} 00:00:00" --until="${FRIDAY} 23:59:59" --no-merges 2>/dev/null || true)
    if [ -n "$commits" ]; then
        stats=$(git log --stat --since="${MONDAY} 00:00:00" --until="${FRIDAY} 23:59:59" --no-merges 2>/dev/null | tail -60)
        COMMIT_DATA="${COMMIT_DATA}
=== ${name} ===
${stats}
"
        REPO_NAMES="${REPO_NAMES}, ${name}"
    fi
done < <(find "$CODE_DIR" -maxdepth 3 -type d -name ".git" -not -path "*/node_modules/*" -print0 2>/dev/null)

REPO_NAMES="${REPO_NAMES#, }"

if [ -z "$REPO_NAMES" ]; then
    echo "[weekly-entry] No commits found for week of ${MONDAY}. Skipping."
    exit 0
fi

REPO_COUNT=$(echo "$REPO_NAMES" | tr ',' '\n' | wc -l | tr -d ' ')
echo "[weekly-entry] Activity in: ${REPO_NAMES} (${REPO_COUNT} repos)"

CLAUDE_BIN=$(command -v claude 2>/dev/null || true)
if [ -z "$CLAUDE_BIN" ]; then
    echo "[weekly-entry] claude CLI not found. Skipping."
    exit 1
fi

POST_PROMPT="Write a lean weekly journal entry for a software engineer's personal blog. Week of ${MONDAY} to ${FRIDAY}.

Git activity this week:

${COMMIT_DATA}

Rules:
- Front matter: layout: post, title (punchy 1-5 word label, not a sentence), date: ${FRIDAY} 12:00:00 -0800, categories: journal weekly
- After front matter on its own line: ![${FRIDAY}](/assets/${FRIDAY}-week.svg)
- Write like a person, not a machine. Short sentences. First person.
- Plain English only. No jargon, no implementation details.
- Describe what changed and why it matters, not how it was built.
- No emojis. No em dashes. No filler. No bullet points in prose.
- Very lean -- short paragraphs. One or two sentences per day or topic.
- Use ## day headers (lowercase: ## monday, ## tuesday, etc.) for notable days. Skip boring days.
- End with ## project sections (one per active repo, use the repo name as header) with a short link and one-line summary.
- Skip auto-sync and trivial commits.
- Output ONLY the markdown file contents."

echo "[weekly-entry] Generating post..."
POST_CONTENT=$(CLAUDECODE="" "$CLAUDE_BIN" -p --model haiku --bare --max-budget-usd 0.08 "$POST_PROMPT" 2>/dev/null || true)

if [ -z "$POST_CONTENT" ] || echo "$POST_CONTENT" | grep -qi "not logged in\|please run /login"; then
    echo "[weekly-entry] Claude auth error or empty output. Skipping."
    exit 1
fi

SVG_PROMPT="Generate an SVG header image for a weekly journal entry. Output ONLY raw SVG markup, no code fences, no explanation.

Week: ${MONTH_DAY} (${WINDOW_LABEL})
Active repos: ${REPO_NAMES}
Repo count: ${REPO_COUNT}

Key activity:
${COMMIT_DATA}

Use this exact structure. Replace bracketed instructions with real values:

<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 800 500\" width=\"800\" height=\"500\">
  <style>
    .bg { fill: #fafafa; }
    .fg { fill: #000; }
    .mut { fill: rgba(0,0,0,0.5); }
    .dim { fill: rgba(0,0,0,0.25); }
    .brd { stroke: rgba(0,0,0,0.1); }
    @media (prefers-color-scheme: dark) {
      .bg { fill: #111; }
      .fg { fill: #e8e8e8; }
      .mut { fill: rgba(255,255,255,0.5); }
      .dim { fill: rgba(255,255,255,0.25); }
      .brd { stroke: rgba(255,255,255,0.1); }
    }
    .t { font-family: Geist, -apple-system, BlinkMacSystemFont, 'SF Pro Display', system-ui, sans-serif; }
    .m { font-family: ui-monospace, SFMono-Regular, 'SF Mono', Menlo, monospace; }
  </style>
  <rect class=\"bg\" width=\"800\" height=\"500\"/>
  <rect class=\"brd\" x=\"20\" y=\"20\" width=\"760\" height=\"460\" rx=\"12\" ry=\"12\" fill=\"none\" stroke-width=\"1\"/>
  <text class=\"t fg\" x=\"48\" y=\"90\" font-size=\"42\" font-weight=\"300\" letter-spacing=\"-1\">Week of ${MONTH_DAY}</text>
  <text class=\"t mut\" x=\"48\" y=\"126\" font-size=\"16\">[3-5 key topics from the week separated by \" . \"]</text>
  <line class=\"brd\" x1=\"48\" y1=\"152\" x2=\"752\" y2=\"152\" stroke-width=\"1\"/>
  [one <text class=\"m fg\" x=\"48\" y=\"N\" font-size=\"14\">REPONAME</text> per repo, starting y=188, spacing 22]
  <text class=\"m mut\" x=\"48\" y=\"[last repo y + 26]\" font-size=\"14\">(${REPO_COUNT} areas)</text>
  <rect class=\"brd\" x=\"560\" y=\"176\" width=\"200\" height=\"270\" rx=\"8\" ry=\"8\" fill=\"none\" stroke-width=\"1\"/>
  <text class=\"m mut\" x=\"584\" y=\"206\" font-size=\"12\">repos</text>
  <text class=\"m fg\" x=\"584\" y=\"232\" font-size=\"28\" font-weight=\"500\">${REPO_COUNT}</text>
  <text class=\"m mut\" x=\"584\" y=\"268\" font-size=\"12\">notable</text>
  [3-4 notable items as <text class=\"m fg\" x=\"584\" y=\"N\" font-size=\"14\">...</text>, starting y=292, spacing 22]
  <text class=\"m mut\" x=\"584\" y=\"392\" font-size=\"12\">window</text>
  <text class=\"m fg\" x=\"584\" y=\"414\" font-size=\"13\">${WINDOW_LABEL}</text>
  <text class=\"t mut\" x=\"48\" y=\"462\" font-size=\"13\">${FRIDAY}</text>
</svg>"

echo "[weekly-entry] Generating SVG..."
SVG_CONTENT=$(CLAUDECODE="" "$CLAUDE_BIN" -p --model haiku --bare --max-budget-usd 0.05 "$SVG_PROMPT" 2>/dev/null || true)

echo "$POST_CONTENT" > "$POST_FILE"
echo "[weekly-entry] Post written: $POST_FILE"

if [ -n "$SVG_CONTENT" ]; then
    echo "$SVG_CONTENT" > "$SVG_FILE"
    echo "[weekly-entry] SVG written: $SVG_FILE"
fi

cd "$JOURNAL_DIR"
git add "_posts/${FRIDAY}-week.md"
[ -f "$SVG_FILE" ] && git add "assets/${FRIDAY}-week.svg"
git commit -m "journal: ${FRIDAY} week" 2>/dev/null || true
git push origin main 2>/dev/null || true

# Publish to Vercel (the push alone does not deploy; journal is CLI-deployed).
"$(dirname "$0")/deploy.sh"

echo "[weekly-entry] Done."
