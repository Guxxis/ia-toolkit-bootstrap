---
name: feedback-no-progress-tracking-m3-rollout
description: Não registrar progresso granular do rollout M3 SSH/Zabbix em memória — usuário controla isso em planilha própria
metadata: 
  node_type: memory
  type: feedback
  originSessionId: ce017408-59f4-4df1-b806-4e2298847643
---

Para o trabalho de [[project_m3_ssh_zabbix_rollout]] (e provavelmente rollouts operacionais parecidos), o usuário já mantém uma planilha de controle de progresso (quais hosts/grupos foram feitos, quais falharam, pendências). Não preciso duplicar isso em memória.

**Why:** ele disse explicitamente "estou usando uma planilha de controle para marcar o progresso, não precisa anotar" quando ofereci salvar uma lista de hosts pendentes.

**How to apply:** continuar salvando achados técnicos duráveis (decisões de arquitetura, causas-raiz não óbvias, ex: incompatibilidade de Python legado) em memória — isso não é progresso, é conhecimento reutilizável. Mas não criar/atualizar entradas tipo "Status (data): fase X feita, fase Y pendente" para esse tipo de execução operacional.
