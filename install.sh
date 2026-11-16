#!/usr/bin/env bash
# Symlink every skill and agent of this repo into ~/.claude.
# Safe to re-run. Never overwrites a real file or folder: it reports it and moves on.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ]; then
    ln -sfn "$src" "$dest"
  elif [ -e "$dest" ]; then
    echo "skip  $dest exists and is not a symlink, move it away first" >&2
    return
  else
    ln -s "$src" "$dest"
  fi
  echo "link  $dest"
}

mkdir -p "$claude/skills" "$claude/agents"
for dir in "$repo"/skills/*/; do
  link "${dir%/}" "$claude/skills/$(basename "$dir")"
done
for file in "$repo"/agents/*.md; do
  link "$file" "$claude/agents/$(basename "$file")"
done

config="$HOME/.config/ai-toolbox/config.yaml"
[ -f "$config" ] || echo "note  no $config yet, copy config.example.yaml there for the jira-* and capture-learnings skills"
