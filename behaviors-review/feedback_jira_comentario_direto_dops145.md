---
name: feedback-jira-comentario-direto-dops145
description: "Na validação diária do DOPS-145 (incidente IDEALPLUS01), postar o comentário de fechamento direto via mcp__jira__jira_add_comment, sem esperar aprovação do rascunho"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 1c7f69c3-f8e8-4bb5-b461-6d8eccbf6ee7
  modified: 2026-08-07T13:04:48.376Z
---

Depois de aplicar as correções pendentes do dia, poste o comentário de fechamento direto no DOPS-145 via `mcp__jira__jira_add_comment` — não precisa mais escrever só um rascunho em arquivo e esperar o usuário colar manualmente.

**Why:** Nos primeiros dias do incidente (04-06/08) os rascunhos eram sempre salvos em arquivo pro usuário copiar e colar ele mesmo. Em 07/08 o usuário disse explicitamente "a ultima parte sempre é o comentario no JIRA" e depois "pode atualizr o dops e fechamos por hoje", confirmando que quer o post direto como etapa final do fluxo diário, não mais um rascunho pendente de aprovação.

**How to apply:** Isso vale para o padrão "faça a análise de hoje" → investigar → corrigir o que estiver pendente → postar o comentário no DOPS-145 como último passo, sem perguntar de novo. Continua valendo a regra separada de [[feedback_aprovacao_antes_de_criar_no_jira]] para *criar* issues/subtarefas novas (isso ainda exige aprovação explícita) — a mudança aqui é só sobre *comentar* em um issue que já existe como parte do ciclo de validação diária deste incidente específico.
