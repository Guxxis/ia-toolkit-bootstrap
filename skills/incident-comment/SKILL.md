---
name: incident-comment
description: Formato padrão e gate de aprovação para comentários no card de origem de um incidente (card do Jira criado pelo Zabbix). É a única via de escrita de comentário das skills incident-triage, incident-plan-refine e incident-postmortem e do agente analista-de-incidentes — usada a cada transição de fase, checkpoint do loop de execução e no comentário final. Use quando precisar registrar andamento de um incidente no card, ou quando o usuário pedir "comenta no card", "registra isso no incidente", "atualiza a task do incidente".
---

# Incident Comment

Padroniza todo comentário escrito no card de origem de um incidente, para
que qualquer pessoa (ou uma sessão nova do agente) consiga ler o card e
saber em que pé está o incidente.

## Formato

```
[Incidente] Fase: <Triagem | Refinamento | Execução | Checkpoint | Postmortem>
Data: YYYY-MM-DD HH:MM

Resumo
<2-4 linhas: o que foi feito/descoberto nesta fase>

Evidências
- <saída de comando, métrica, log — curto, só o que sustenta o resumo>

Decisões
- <o que foi decidido e por quê; "nenhuma" se não houver>

Próximos passos
- <próxima ação concreta e quem executa>

Pendências
- <o que depende de alguém/algo; "nenhuma" se não houver>
```

Regras do formato:

- Nunca use `**negrito**` — corrompe no round-trip markdown↔wiki do MCP do
  Atlassian. Use títulos de seção em linha própria, listas com `-` e blocos
  de código com três crases para evidências.
- Evidência é trecho curto. Saída longa: resuma e cite o comando usado.
- Seção sem conteúdo fica com "nenhuma", não é removida — o formato fixo é
  o que permite retomar o estado lendo o card.
- Nunca inclua IP interno, senha, token ou conteúdo de `.env`.
- A fase Postmortem pode trocar Evidências/Decisões por um resumo da causa
  raiz e o link do arquivo no Drive (ver `incident-postmortem`).

## Gate de aprovação

- Chamada manual pelo usuário (ex.: ele rodou `incident-triage`): a chamada
  já é a permissão — poste direto e informe o link do comentário.
- Disparo pelo próprio agente/skill (fim do refinamento, checkpoint do
  loop, postmortem): mostre o rascunho completo ao usuário e só poste
  depois de um "ok"/"pode postar" explícito. Silêncio ou mudança de assunto
  não é aprovação. Se ele pedir ajuste, mostre o rascunho de novo.

## Postagem

`mcp__claude_ai_Atlassian__addCommentToJiraIssue` na chave do card de
origem (não numa subtask, a menos que o usuário peça). Nunca edite
summary/descrição nem transicione status a partir desta skill.
