#!/usr/bin/env bash
# Lista em JSON os chamados GLPI abertos com o usuário do token como técnico atribuído.
set -euo pipefail

ENV_FILE="${GLPI_RADAR_ENV:-$HOME/.config/glpi-radar.env}"
[ -f "$ENV_FILE" ] || { echo "faltando $ENV_FILE (GLPI_URL, GLPI_APP_TOKEN, GLPI_USER_TOKEN)" >&2; exit 1; }
# shellcheck disable=SC1090
source "$ENV_FILE"
: "${GLPI_URL:?}" "${GLPI_APP_TOKEN:?}" "${GLPI_USER_TOKEN:?}"

# GLPI Network Cloud: v1 só roteia em /api/ (apirest.php/* devolve SESSION_TOKEN_MISSING até no initSession)
API="${GLPI_URL%/}/api"
H_APP="App-Token: $GLPI_APP_TOKEN"

session=$(curl -fsS -H "$H_APP" -H "Authorization: user_token $GLPI_USER_TOKEN" "$API/initSession" | jq -r .session_token)
trap 'curl -fsS -H "$H_APP" -H "Session-Token: $session" "$API/killSession" >/dev/null || true' EXIT

me=$(curl -fsS -H "$H_APP" -H "Session-Token: $session" "$API/getFullSession" | jq -r .session.glpiID)

# campos: 1 título, 2 id, 12 status, 15 abertura, 21 descrição; 5 = técnico atribuído; status notold = não solucionado/fechado
curl -fsS -G -H "$H_APP" -H "Session-Token: $session" "$API/search/Ticket" \
  --data-urlencode "criteria[0][field]=5" \
  --data-urlencode "criteria[0][searchtype]=equals" \
  --data-urlencode "criteria[0][value]=$me" \
  --data-urlencode "criteria[1][link]=AND" \
  --data-urlencode "criteria[1][field]=12" \
  --data-urlencode "criteria[1][searchtype]=equals" \
  --data-urlencode "criteria[1][value]=notold" \
  --data-urlencode "forcedisplay[0]=1" \
  --data-urlencode "forcedisplay[1]=2" \
  --data-urlencode "forcedisplay[2]=12" \
  --data-urlencode "forcedisplay[3]=15" \
  --data-urlencode "forcedisplay[4]=21" \
  --data-urlencode "range=0-500" \
| jq --arg url "${GLPI_URL%/}" '[.data // [] | .[] | {
    id: .["2"],
    titulo: .["1"],
    status: .["12"],
    abertura: .["15"],
    link: "\($url)/front/ticket.form.php?id=\(.["2"])",
    descricao: ((.["21"] // "") | gsub("&lt;";"<") | gsub("&gt;";">") | gsub("&amp;";"&") | gsub("<[^>]*>";" ") | gsub("&nbsp;";" ") | gsub("\\s+";" ") | .[0:400])
  }]'
