---
name: feedback-jira-tickets-sempre-dops
description: "Tarefas do Jira criadas para o usuário sempre vão no projeto DOPS como História presa ao Épico DOPS-156, nunca soltas ou no board do produto afetado"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: abbe5234-4fe1-47f0-84be-a2e9165e6aea
  modified: 2026-08-06T23:10:54.382Z
---

Ao criar uma tarefa/ticket no Jira a pedido direto do usuário para o próprio trabalho dele, sempre: projeto `DOPS`, tipo `História` (nunca `Tarefa` direto), `parent: DOPS-156` (Épico Tickets) — mesmo quando o assunto é sobre outro sistema (ex: IdealTrack → projeto `IT`) e mesmo quando o pedido já vem detalhado (prazo/esforço prontos), não só em formalização de GLPI/boca a boca.

**Why:** o usuário é do time de infra/DevOps; o board do produto (`IT`, `AI`, etc.) pertence ao time de desenvolvimento daquele produto. Ficou explícito em duas correções seguidas: primeiro criei IT-1822 (sobre IdealTrack) direto no projeto `IT` — teve que ser recriado como DOPS-199 (`IT-1822` não pôde ser deletado via API, sem permissão, só comentado pedindo exclusão manual); depois criei o DOPS-199 como `Tarefa` solta, sem Épico — teve que ser convertido para `História` e linkado a `DOPS-156` depois. Causa raiz dos dois: criei a issue "à mão" com `jira_create_issue` direto em vez de seguir o fluxo da skill [[reference_jira_ticket_creator_skill]].

**How to apply:** sempre que o usuário disser "cria/abre um ticket/tarefa no Jira" para o próprio trabalho, invocar a skill `jira-ticket-creator` (passos 1-5) em vez de chamar `jira_create_issue` direto — o fluxo da skill já força projeto DOPS + tipo História + parent DOPS-156. Regra também documentada em `/root/.claude/commands/jira-ticket-creator/SKILL.md`.
