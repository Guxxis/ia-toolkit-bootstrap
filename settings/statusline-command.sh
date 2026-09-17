#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
DIR=$(basename "$(echo "$input" | jq -r '.workspace.current_dir')")
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
TRANSCRIPT=$(echo "$input" | jq -r '.transcript_path // empty')

DIM='\033[2m'; CYAN='\033[2;36m'; MAGENTA='\033[2;35m'; BLUE='\033[2;34m'; RESET='\033[0m'
GREEN='\033[2;32m'; YELLOW='\033[2;33m'; RED='\033[2;31m'

if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

LIMITS=""
[ -n "$FIVE_H" ] && LIMITS="5h:$(printf '%.0f' "$FIVE_H")%"
[ -n "$WEEK" ] && LIMITS="${LIMITS:+$LIMITS }7d:$(printf '%.0f' "$WEEK")%"

# ponytail: session start read from first transcript line's timestamp;
# falls back to empty (field omitted) if missing/unparseable.
DUR=""
if [ -f "$TRANSCRIPT" ]; then
  START_TS=$(head -n 1 "$TRANSCRIPT" | jq -r '.timestamp // empty' 2>/dev/null)
  if [ -n "$START_TS" ]; then
    START_EPOCH=$(date -d "$START_TS" +%s 2>/dev/null)
    if [ -n "$START_EPOCH" ]; then
      DIFF=$(($(date +%s) - START_EPOCH))
      H=$((DIFF / 3600)); M=$(((DIFF % 3600) / 60))
      [ "$H" -gt 0 ] && DUR="${H}h${M}m" || DUR="${M}m"
    fi
  fi
fi

OUT="${CYAN}${MODEL}${RESET}"
[ -n "$EFFORT" ] && OUT="${OUT} ${DIM}·${RESET} ${MAGENTA}${EFFORT}${RESET}"
OUT="${OUT} ${DIM}·${RESET} ${BAR_COLOR}${BAR}${RESET} ${PCT}%"
[ -n "$LIMITS" ] && OUT="${OUT} ${DIM}·${RESET} ${GREEN}${LIMITS}${RESET}"
[ -n "$DUR" ] && OUT="${OUT} ${DIM}·${RESET} ${BLUE}${DUR}${RESET}"
OUT="${OUT} ${DIM}·${RESET} ${DIM}${DIR}${RESET}"

printf "%b\n" "$OUT"
