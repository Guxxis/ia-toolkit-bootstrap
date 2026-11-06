#!/bin/bash
# Uso: run-agent.sh <agente> <prompt> — roda o agente headless só com as tools do frontmatter dele.
set -uo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

agent=$1
prompt=$2
agent_file="${AGENT_DIR:-$HOME/.claude/agents}/$agent.md"
log_dir="$HOME/workspace/temp/cron"
mkdir -p "$log_dir"

# Bash do backoffice fica restrito ao script do glpi-radar.
IFS=',' read -ra tools <<< "$(sed -n 's/^tools: //p' "$agent_file")"
allowed=()
for t in "${tools[@]}"; do
  t=$(echo "$t" | xargs)
  [ "$t" = "Bash" ] && t="Bash(bash ~/.claude/skills/glpi-radar/glpi-open-tickets.sh)"
  allowed+=("$t")
done

cd "${RUN_DIR:-$HOME/workspace}" || exit 1
{
  echo "=== $(date '+%F %T') | $prompt"
  flock -n "$log_dir/$agent.lock" \
    claude -p "$prompt" --agent "$agent" --permission-mode dontAsk --allowedTools "${allowed[@]}" \
    || echo "rc=$? (lock ocupado ou falha)"
} >> "$log_dir/$agent.log" 2>&1
