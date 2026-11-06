---
name: jira-sprint
description: Monta a próxima sprint do DOPS (2 semanas) — lista o backlog sem sprint e as sobras de sprints fechadas, sinaliza o óbvio (prazo vencido, prioridade alta, já em andamento) e, só após aprovação explícita, coloca as issues escolhidas na sprint. Use quando o usuário disser "monta a sprint", "o que entra na próxima sprint", "backlog do DOPS", "planejamento da sprint". Manual, nunca agendado. Não use para criar espelhos de órfãos (isso é jira-radar) nem para relatório de estagnados/espelhos (isso é jira-saude).
---

# Jira Sprint (montagem da sprint do DOPS)

## Relação com outras skills (não duplicar)

Épicos, formato de descrição e gate de aprovação vêm de
`jira-ticket-creator`; conector, `cloudId`, `view: "full"`, prioridade por
`id` e `parent` como objeto vêm de "Descobertas técnicas" de `jira-radar`.
Releia os dois antes de editar qualquer issue — se divergirem desta skill,
eles são a fonte de verdade.

Desde 2026-10-20 as sprints do DOPS têm 2 semanas (antes eram de 1
semana), alinhadas à convenção dos outros times.

## Buscar candidatos de backlog

JQL:
```
project = DOPS AND sprint is EMPTY AND statusCategory != Done ORDER BY priority DESC, created ASC
```

`sprint is EMPTY` não pega issue não concluída que já passou por sprint
fechada e não foi movida para a próxima (o histórico em `customfield_10010`
fica preenchido). Rodar também:
```
project = DOPS AND statusCategory != Done AND sprint in closedSprints() AND sprint not in openSprints() AND sprint not in futureSprints() ORDER BY priority DESC, created ASC
```
e apresentar esses itens separados na proposta, citando por quais sprints
já passaram.

## Descobrir a sprint ativa

Sem ferramenta de agile board neste MCP:
```
project = DOPS AND sprint in openSprints()
```
Leia o campo `customfield_10010` de qualquer issue retornada — é um array
de objetos `{id, name, state, boardId, startDate, endDate}`. O de
`state: "active"` é a sprint ativa; se precisar da próxima (futura),
procure `state: "future"` no mesmo campo, ou pergunte ao usuário o
nome/id se nenhuma issue existente ainda referencia a próxima.

Se `openSprints()` voltar vazio (sprint anterior já fechada e a nova ainda
não iniciada), usar `project = DOPS AND sprint in futureSprints()` e ler o
`state: "future"` do mesmo campo.

## Propor

Tabela: candidato (chave + título), Épico atual, esforço
(`customfield_10092` se já setado, senão "sem estimativa"), prazo, e um
sinal óbvio quando aplicável (prazo vencido, prioridade alta, já em
andamento). Pergunte ao usuário, em texto corrido, o que entra — **sem
cálculo de capacidade/orçamento de story points**: a skill só organiza os
candidatos e sinaliza o óbvio, a decisão de quanto entra é inteiramente do
usuário.

## Aprovação e aplicação

Só após "pode seguir"/equivalente: editar cada issue aprovada, setando
`customfield_10010` para o **id inteiro** da sprint escolhida (ver
"Campo Sprint" abaixo) e `customfield_10092` se story points também foi
decidido agora. Não mexe em status/transição — isso é do usuário.

## Campo Sprint (`customfield_10010`)

- **Peculiaridade get vs. set:** na leitura vem como array de objetos
  `[{id, name, state, boardId, startDate, endDate}, ...]`; para **setar**
  (criação ou edição de issue), o valor aceito é o **id inteiro simples**
  da sprint, não o array/objeto. Ex.: `{"customfield_10010": 4413}`.
  Peculiaridade real do Jira Cloud, não bug do MCP.
- Em 2026-11 o `createJiraIssue` do Atlassian MCP passou a converter esse
  valor em `["4413"]` e o Jira recusa; na criação, usar o parâmetro
  `assignToSprint` (id numérico) em vez do campo.

## Capacidade observada (referência estática, não é cálculo automático)

Método: somar `customfield_10092` das issues concluídas (sem Épico e
Subtarefa), atribuídas pela **data de conclusão (`resolutiondate`) dentro
da janela `startDate`/`completeDate` da sprint** — não pela simples
presença no array de `customfield_10010`, que guarda todo o histórico de
sprints por onde a issue passou (usar `sprint = X` na JQL conta issues
retrabalhadas em mais de uma sprint em dobro). Issue sem estimativa conta
como 0, então todo número é piso.

Histórico das sprints de 1 semana (levantado em 2026-10-19):

| Sprint | Janela | SP entregues | Issues (sem SP) |
|---|---|---|---|
| SPRINT 6 | 18/08–25/08 | 21 | ? (5) |
| SPRINT 7 | 25/08–01/09 | 55 | — |
| SPRINT 8 | 01/09–08/09 | 16 | — |
| SPRINT 9 | 08/09–15/09 | 14 | 4 (0) |
| SPRINT 10 | 15/09–22/09 | 43 | 15 (0) |
| SPRINT 11 | 22/09–29/09 | 58 | 24 (0) |
| SPRINT 12 | 29/09–06/10 | 35 | 28 (13) |
| SPRINT 13 | 06/10–13/10 | 22 | 17 (6) |
| SPRINT 14 | 13/10–20/10 | 27 até 19/10 | 20 (9) |

- Média semanal das 8 sprints fechadas (S6–S13): ≈33 SP/semana; das 3
  mais recentes (S12–S14): ≈28 SP/semana.
- Pares de semanas como janela de 2 semanas: S6+S7 = 76, S8+S9 = 30,
  S10+S11 = 101, S12+S13 = 57 → média ≈66 SP.
- Referência inicial para sprint de 2 semanas: ≈60 SP (faixa 50–70).
  A variância semana a semana é alta (14 a 58) e a fatia de issues sem SP
  cresceu desde a S12, o que puxa os números para baixo.

Isto é só uma nota de contexto — o usuário decidiu não ter cálculo de
capacidade automático, a decisão de quanto entra na sprint continua sendo
dele. Ao usar esta skill, cite a referência e, a cada sprint de 2 semanas
fechada, recalcule e acrescente uma linha numa tabela de sprints de 2
semanas — os 60 SP são para ser regulados com o tempo, não permanentes.
Com 3 ou mais sprints de 2 semanas fechadas, passe a usar só elas e
descarte a conversão das semanais.
