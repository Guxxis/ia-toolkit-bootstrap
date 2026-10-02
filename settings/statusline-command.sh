#!/usr/bin/env bash
# Compact statusline: model | effort | context bar | 5h% | 7d% | duration | folder
input=$(cat)

R='\033[0m'
C_MODEL='\033[2;36m'
C_EFFORT='\033[2;35m'
C_BAR='\033[2;33m'
C_5H='\033[2;32m'
C_7D='\033[2;32m'
C_DUR='\033[2;34m'
C_DIR='\033[2;37m'

model=$(printf '%s' "$input" | jq -r '.model.display_name // "?"')

effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')
[ -z "$effort" ] && effort="-"

used=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  used_i=$(printf '%.0f' "$used")
else
  used_i=0
fi
[ "$used_i" -gt 100 ] 2>/dev/null && used_i=100
bar_len=10
filled=$(( used_i * bar_len / 100 ))
[ "$filled" -gt "$bar_len" ] && filled=$bar_len
bar=$(printf '#%.0s' $(seq 1 "$filled" 2>/dev/null))
empty=$(printf '.%.0s' $(seq 1 $((bar_len - filled)) 2>/dev/null))

five=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
[ -n "$five" ] && five=$(printf '%.0f' "$five") || five="-"

week=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
[ -n "$week" ] && week=$(printf '%.0f' "$week") || week="-"

transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
dur="-"
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  first_ts=$(head -n1 "$transcript" 2>/dev/null | jq -r '.timestamp // empty' 2>/dev/null)
  if [ -n "$first_ts" ]; then
    start_epoch=$(date -d "$first_ts" +%s 2>/dev/null)
    if [ -n "$start_epoch" ]; then
      diff=$(( $(date +%s) - start_epoch ))
      h=$(( diff / 3600 )); m=$(( (diff % 3600) / 60 ))
      if [ "$h" -gt 0 ]; then dur="${h}h${m}m"; else dur="${m}m"; fi
    fi
  fi
fi

cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
folder=$(basename "${cwd:-.}")

printf "${C_MODEL}%s${R} ${C_EFFORT}%s${R} ${C_BAR}[%s%s]%d%%${R} ${C_5H}5h:%s%%${R} ${C_7D}7d:%s%%${R} ${C_DUR}%s${R} ${C_DIR}%s${R}\n" \
  "$model" "$effort" "$bar" "$empty" "$used_i" "$five" "$week" "$dur" "$folder"
