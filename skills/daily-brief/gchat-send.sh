#!/usr/bin/env bash
# Envia o stdin ao webhook do Google Chat uma vez por dia; --check só diz se já foi enviado.
set -euo pipefail

url_file="${GCHAT_WEBHOOK_FILE:-$HOME/.config/gchat-webhook}"
mark="$HOME/workspace/temp/cron/brief-$(date +%F).sent"

if [ -f "$mark" ]; then echo "briefing de hoje já enviado ao Chat"; exit 0; fi
if [ "${1:-}" = "--check" ]; then echo "briefing de hoje ainda não enviado"; exit 0; fi
[ -s "$url_file" ] || { echo "faltando $url_file (URL do webhook)" >&2; exit 1; }
url=$(<"$url_file")
text=$(cat)
[ -n "$text" ] || { echo "texto vazio" >&2; exit 1; }

send() {
  jq -n --arg t "$1" '{text: $t}' |
    curl -fsS -X POST -H 'Content-Type: application/json; charset=UTF-8' --data-binary @- "$url" >/dev/null
}

# Chat aceita até 4096 caracteres por mensagem: corta por linha.
chunk=""
while IFS= read -r line; do
  if [ -n "$chunk" ] && [ $(( ${#chunk} + ${#line} + 1 )) -gt 4000 ]; then
    send "$chunk"; chunk=""
  fi
  chunk+="${chunk:+$'\n'}$line"
done <<< "$text"
[ -n "$chunk" ] && send "$chunk"

mkdir -p "$(dirname "$mark")" && touch "$mark"
echo "briefing enviado ao Chat"
