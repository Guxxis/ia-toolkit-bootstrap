---
name: feedback-jira-comentario-direto-dops330
description: "Na validação diária do DOPS-330/336 (hardening pós-incidente IDEALPLUS02/HOMOLOG), postar o comentário de fechamento direto via mcp__jira__jira_add_comment, sem esperar aprovação do rascunho"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 4518e693-31e0-499f-a795-ddb3d8e27d71
  modified: 2026-08-20T18:21:09.190Z
---

Depois de rodar o ciclo diário de validação (DOPS-336: recontagem de admins, IOC de arquivo, guardian ativo, verify-checksums, reteste de bypasses) nos servidores IDEALPLUS02 e IDEALPLUS-HOMOLOG, poste o resumo do dia direto no DOPS-330 via `mcp__jira__jira_add_comment` — não precisa de rascunho nem esperar aprovação do texto.

**Why:** em 20/08/2026 o usuário disse explicitamente "atualiza o DOPS-330 com oque foi feito no comentario, todo dia faremos essa mesma analise" — mesmo padrão já estabelecido em [[feedback_jira_comentario_direto_dops145]] pra ciclos de validação diária de incidente.

**How to apply:** todo dia que rodar a varredura do IDEALPLUS02/HOMOLOG (contas backdoor removidas, guardian corrigido, achados novos, resultado do fleet-wide scan), postar comentário consolidado no DOPS-330 como último passo, sem perguntar de novo. Continua valendo [[feedback_aprovacao_antes_de_criar_no_jira]] pra *criar* issues novas (isso ainda exige aprovação) — a exceção é só sobre *comentar* no DOPS-330 já existente.

Nota de ferramenta: o parâmetro correto do `jira_add_comment` é `body`, não `comment`.
