#!/usr/bin/env bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_part=""
if [ -n "$used" ]; then
  ctx_part=" \033[01;33m[ctx: $(printf '%.0f' "$used")%]\033[00m"
fi
printf "\033[01;32m$(whoami)@$(hostname -s)\033[00m:\033[01;34m${cwd:-$(pwd)}\033[00m${ctx_part}"
