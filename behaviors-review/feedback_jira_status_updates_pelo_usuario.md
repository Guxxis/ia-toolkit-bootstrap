---
name: feedback-jira-status-updates-pelo-usuario
description: Usuário faz as transições de status e comentários no Jira ele mesmo; Claude só valida tecnicamente
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 39d0ac42-ae5b-4df4-b866-af4cd2eda54b
  modified: 2026-08-03T15:23:11.836Z
---

Quando o trabalho envolve validar tarefas do Jira (ex.: tickets "Em Teste" aguardando confirmação), fazer a validação técnica real (acessar ambiente, checar config/código/infra) mas **não** comentar ou transicionar status no Jira — o usuário faz essa parte manualmente.

**Why:** instrução explícita ("não precisa comentar nada no JIRA, eu faço a atualização por lá"), dada durante validação de infra (IT-1175/1176/1177 do projeto IdealTrack).

**How to apply:** ao receber pedido de "validar"/"dar sequência" em tickets, focar em achar evidência técnica concreta (acesso a servidor, kubectl, logs, etc.) e reportar o resultado em texto — deixar a ação no Jira (mover status, comentar, fechar) para o usuário, a menos que ele peça explicitamente o contrário numa conversa futura. Complementa [[feedback_no_progress_tracking_m3_rollout]] (não rastrear progresso operacional em memória).
