#!/bin/bash
# Uso: run-agent.sh <agente> <prompt> — roda o agente headless só com as tools do frontmatter dele.
set -uo pipefail
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

agent=$1
prompt=$2
agent_file="${AGENT_DIR:-$HOME/.claude/agents}/$agent.md"
log_dir="$HOME/workspace/temp/cron"
mkdir -p "$log_dir"

# Bash de cada agente fica restrito ao script da skill dele.
case $agent in
  agente-backoffice) bash_rule="Bash(bash ~/.claude/skills/glpi-radar/glpi-open-tickets.sh)" ;;
  agente-consultor) bash_rule="Bash(bash ~/.claude/skills/daily-brief/gchat-send.sh:*)" ;;
  *) bash_rule="" ;;
esac
IFS=',' read -ra tools <<< "$(sed -n 's/^tools: //p' "$agent_file")"
allowed=()
for t in "${tools[@]}"; do
  t=$(echo "$t" | xargs)
  [ "$t" = "Bash" ] && t=$bash_rule
  [ -n "$t" ] && allowed+=("$t")
done

cd "${RUN_DIR:-$HOME/workspace}" || exit 1
{
  echo "=== $(date '+%F %T') | $prompt"
  flock -n "$log_dir/$agent.lock" \
    claude -p "$prompt" --agent "$agent" --permission-mode dontAsk --allowedTools "${allowed[@]}" \
    || echo "rc=$? (lock ocupado ou falha)"
} >> "$log_dir/$agent.log" 2>&1
