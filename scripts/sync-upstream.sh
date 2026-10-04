#!/usr/bin/env bash
# Sync this fork with cursor/plugins/pstack (Lauren Tan's original).
#   scripts/sync-upstream.sh          update `upstream`, merge into `main`, report new Cursor-only text
#   scripts/sync-upstream.sh --check  report only (exit 1 when Cursor is ahead)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_REPO="https://github.com/cursor/plugins.git"
check=0; [ "${1:-}" = "--check" ] && check=1
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

git clone --quiet --filter=blob:none --sparse "$SRC_REPO" "$tmp/plugins"
git -C "$tmp/plugins" sparse-checkout set pstack >/dev/null
remote_sha="$(git -C "$tmp/plugins" log -1 --format=%h -- pstack)"
remote_ver="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$tmp/plugins/pstack/.cursor-plugin/plugin.json" | head -1)"
local_sha="$(git -C "$ROOT" log -1 --format=%s upstream | sed -n 's/.*@ \([0-9a-f]*\).*/\1/p')"

# Compare the pstack folder itself; the plugins repo moves for other plugins too.
mkdir -p "$tmp/ours"; git -C "$ROOT" archive upstream | tar -x -C "$tmp/ours"
if diff -rq --exclude MIRROR.md --exclude scripts "$tmp/plugins/pstack" "$tmp/ours" >/dev/null; then
  echo "current: upstream branch matches cursor/plugins/pstack ($remote_ver @ $remote_sha; ours @ ${local_sha:-?})"; exit 0
fi
echo "ahead:   cursor/plugins/pstack is $remote_ver @ $remote_sha; our upstream branch is @ ${local_sha:-?}"
{ diff -rq --exclude MIRROR.md --exclude scripts "$tmp/plugins/pstack" "$tmp/ours" || true; } | sed 's|'"$tmp"'/plugins/pstack/||; s|'"$tmp"'/ours/||' | head -60
[ $check = 1 ] && exit 1

[ -z "$(git -C "$ROOT" status --porcelain)" ] || { echo "working tree not clean; commit or stash first" >&2; exit 2; }
start="$(git -C "$ROOT" branch --show-current)"
git -C "$ROOT" switch --quiet upstream
rsync -a --delete --exclude .git --exclude MIRROR.md --exclude scripts "$tmp/plugins/pstack/" "$ROOT/"
git -C "$ROOT" add -A
git -C "$ROOT" commit --quiet -m "upstream: cursor/plugins/pstack @ $remote_sha ($remote_ver)"
echo "new Cursor-only instructions in this delta (rewrite per MIRROR.md):"
git -C "$ROOT" diff upstream@{1} upstream -- skills | grep -nE '^\+.*(\.cursor/|agent-transcripts|cursor-team-kit|create-skill|environment: "cloud"|AskQuestion)' | cut -c1-160 || echo "  none"
git -C "$ROOT" switch --quiet main
if git -C "$ROOT" merge upstream -m "Merge upstream pstack $remote_ver (cursor/plugins @ $remote_sha)"; then
  echo "merged cleanly into main. Review, cp agents/comment-sicko.md skills/no-comments/references/comment-sicko.md, then: git push origin main upstream"
else
  echo "CONFLICTS. Keep Cursor's new meaning, reapply harness-neutral wording, then: git add -A && git commit"; exit 3
fi
