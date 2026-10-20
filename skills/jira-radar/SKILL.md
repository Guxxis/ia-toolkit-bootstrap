---
name: jira-radar
description: Varre o Jira periodicamente por quatro ângulos — (1) issues assignadas ao usuário fora do projeto DOPS que ainda não têm nenhum Linked Work Item DOPS-*, (2) backlog do DOPS sem sprint atribuída, para ajudar a montar a próxima sprint (2 semanas), (3) issues do DOPS sem atualização há vários dias (estagnadas), e (4) issues-espelho do DOPS cuja issue original já foi concluída, candidatas a fechar. Propõe em tabela ou lista, nunca escreve sem aprovação explícita quando o modo envolve criar/editar. Usa as mesmas convenções de Épico, formato de descrição e aprovação da skill jira-ticket-creator — não as redefine. Use quando o usuário disser "roda o radar", "vê o que tá sem ticket no DOPS", "monta a sprint", "o que entra na próxima sprint", "backlog do DOPS", "tickets parados/estagnados", "os espelhos já podem fechar", ou periodicamente a pedido dele. Não use para formalizar um pedido novo que acabou de chegar (isso é jira-ticket-creator).
---

# Jira Radar

## Relação com jira-ticket-creator (não duplicar)

Esta skill **não redefine** nada que já está fixado em `jira-ticket-creator`:
tabela de Épicos, formato de descrição (Pedido/Origem/Contexto adicional),
proibição de `**negrito**` na descrição, gate de aprovação explícita. Antes
de montar qualquer proposta ou criar/editar qualquer issue, releia
`skills/jira-ticket-creator/SKILL.md` (seções "Épicos de destino" e
"Aplicação") e siga o que estiver lá. Se um dia esta skill e aquela
divergirem, a fonte de verdade é `jira-ticket-creator` — ajuste este
arquivo, não o contrário.

Quatro modos, cada um pode ser acionado independente dos outros.

## Modo 1 — Radar de órfãos (fora do DOPS, sem link para DOPS)

### Buscar candidatos

JQL:
```
assignee = currentUser() AND project != DOPS AND statusCategory != Done
```
via a ferramenta de busca JQL do MCP Atlassian ativo, pedindo o campo
`issuelinks` no retorno (além dos campos default).

### Filtrar

Descarte qualquer issue cujos `issuelinks` já apontem para uma chave
`DOPS-*` (inward ou outward, qualquer tipo de link — já tem rastreio, não
duplicar). O que resta são os órfãos.

**Limitação conhecida:** o filtro olha só `issuelinks` nativo do Jira. Um
link remoto (uma URL colada em vez de um link Jira nativo) para uma issue
DOPS não seria pego por esse filtro — pior caso é propor uma issue que já
tem rastreio, e o usuário recusa na Proposta. Não é crítico, mas não finja
que o filtro é perfeito.

### Propor

Mesma tabela de `jira-ticket-creator` (Issue/Título, Categoria/Épico,
Sprint, Prazo, Esforço, Responsável) — uma linha por órfão, citando a issue
original (chave + link) na primeira coluna. Categoria/Épico é sugestão sua
com base no conteúdo da issue original; pergunte o que estiver ambíguo, em
texto corrido, na mesma mensagem — **nunca `AskUserQuestion` nesta etapa**
(mesma regra do Brainstorm em `jira-ticket-creator`: as respostas aqui são
abertas, não uma escolha fechada).

Antes de propor, vale conferir rapidamente se já existe algo relacionado no
DOPS (busca por palavra-chave), mesmo sem link direto — evita propor
duplicata.

### Aprovação e aplicação

Idêntico a `jira-ticket-creator`: pergunta única de "posso criar?", silêncio
não é aprovação. Aplicado o aprovado: para cada órfão, criar a issue no
DOPS com o mesmo formato de descrição (Pedido/Origem/Contexto adicional,
citando a issue original como "Origem"), vinculada ao Épico certo via campo
`parent` (ver "Descobertas técnicas" — precisa ser um objeto, não string),
depois criar o link tipo `Relates` entre a issue nova e a original.

**Título do espelho:** `[<CHAVE-ORIGINAL>] <texto do que precisa fazer>` —
ex. `[IT-165] texto do que precisa fazer`, `[IDEAL-6848] outra coisa pra
fazer`. Não usar o prefixo `[Espelho <CHAVE>]` (formato antigo). O objetivo
é identificar projeto/task de cara pela lista do DOPS, sem precisar abrir o
link relacionado — o link `Relates` continua sendo criado normalmente, só é
aberto quando for preciso mais contexto ou para deixar o comentário final
de conclusão.

## Modo 2 — Montagem da sprint (2 semanas)

Desde 2026-10-20 as sprints do DOPS têm 2 semanas (antes eram de 1
semana), alinhadas à convenção dos outros times.

### Buscar candidatos de backlog

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

### Descobrir a sprint ativa

Sem ferramenta de agile board neste MCP (ver "Descobertas técnicas"):
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

### Propor

Tabela: candidato (chave + título), Épico atual, esforço
(`customfield_10092` se já setado, senão "sem estimativa"), prazo, e um
sinal óbvio quando aplicável (prazo vencido, prioridade alta, já em
andamento). Pergunte ao usuário, em texto corrido, o que entra — **sem
cálculo de capacidade/orçamento de story points**: o radar só organiza os
candidatos e sinaliza o óbvio, a decisão de quanto entra é inteiramente do
usuário.

### Aprovação e aplicação

Só após "pode seguir"/equivalente: editar cada issue aprovada, setando
`customfield_10010` para o **id inteiro** da sprint escolhida (não o
objeto/array que vem na leitura — ver "Descobertas técnicas") e
`customfield_10092` se story points também foi decidido agora. Não mexe em
status/transição — isso é do usuário.

### Capacidade observada (referência estática, não é cálculo automático)

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
capacidade automático neste modo, a decisão de quanto entra na sprint
continua sendo dele. Ao usar este modo, cite a referência e, a cada sprint
de 2 semanas fechada, recalcule e acrescente uma linha numa tabela de
sprints de 2 semanas — os 60 SP são para ser regulados com o tempo, não
permanentes. Com 3 ou mais sprints de 2 semanas fechadas, passe a usar só
elas e descarte a conversão das semanais.

## Modo 3 — Saúde do DOPS (somente leitura, sem gate de aprovação)

Os dois submodos abaixo só relatam, nunca escrevem nada sozinhos — por isso
não precisam de aprovação prévia. Se o usuário pedir uma ação a partir do
relatório (comentar, fechar, criar algo), aí sim cai no fluxo normal de
aprovação de `jira-ticket-creator`/Modo 1-2 desta skill.

### 3.1 Tickets estagnados

JQL:
```
project = DOPS AND statusCategory != Done AND updated <= -14d ORDER BY updated ASC
```
14 dias é o default; se o usuário pedir outro limite ("mostra parado há mais
de 30 dias"), use o dele. Reporte em lista simples: chave, título,
responsável, data da última atualização, dias parado.

**Prioridade dos Épicos (não tratar toda estagnação igual):** os Épicos
DOPS-1, 46, 47, 48, 49 e 50 são projetos internos de melhoria/padronização da
área de DevOps — importantes, mas sem SLA externo. DOPS-156, 207 e 208 são
solicitações de terceiros (outro time ou empresa da holding) com prazo e SLA
de resposta. Ao reportar estagnados, separar ou rebaixar a urgência de
issues estagnadas dentro de DOPS-1/46-50 frente às estagnadas dentro de
DOPS-156/207/208 — estas últimas são o sinal que realmente importa.

### 3.2 Sincronia de espelhos

Busque issues do DOPS ainda não concluídas (`statusCategory != Done`) que
tenham `issuelinks` do tipo `Relates` apontando para fora do DOPS. Para cada
uma, o status da issue linkada já vem embutido no payload de `issuelinks` —
não precisa de chamada extra. Se a original estiver com `statusCategory`
"Concluído"/Done, sinalize como candidata a fechar: "a original X foi
concluída — considere transicionar/fechar o espelho DOPS-Y". Nunca
transiciona nem comenta sozinho, só avisa.

## Descobertas técnicas (instância idealtrends.atlassian.net, projeto DOPS)

> Válidas em 2026-09. Se algo aqui parar de funcionar, revalidar antes de
> assumir que o código/JQL está errado — a causa mais provável é a
> instância ter mudado (reprojetar board, reconfigurar campo), não a skill.

- O MCP Atlassian ativo nesta conta é o conector "Atlassian MCP", prefixo
  `mcp__claude_ai_Atlassian_MCP__*` (busca por JQL, leitura/criação/edição
  de issue; criação de link via `discover` → `executeWrite`
  `createJiraIssueLink`), sempre com `cloudId: "idealtrends.atlassian.net"`.
  O conector "Atlassian" (`mcp__claude_ai_Atlassian__*`) responde 403 "app
  is not installed", e o antigo `mcp:jira`/`jira_*` não existe mais. Já
  houve drift silencioso de nome de MCP mais de uma vez; se acontecer de
  novo, procure no MCP ativo o equivalente antes de assumir que o Jira caiu.
- Na busca JQL, `issuelinks` e custom fields só voltam com `view: "full"`
  (ou `"evidence"`) — a view compacta default os omite mesmo pedindo o
  campo, o que faria todo issue parecer órfão no Modo 1.
- Prioridade: setar pelo `id` (1 Muito Alta, 2 Alta, 3 Média, 4 Baixa) —
  ver tabela em `jira-ticket-creator`; `name` em inglês é rejeitado.
- Sem ferramenta de agile board neste MCP: descobrir a sprint ativa via JQL
  `project = DOPS AND sprint in openSprints()` e ler `customfield_10010` do
  resultado.
- Campo Sprint: `customfield_10010`. **Peculiaridade get vs. set:** na
  leitura vem como array de objetos `[{id, name, state, boardId,
  startDate, endDate}, ...]`; para **setar** (criação ou edição de issue),
  o valor aceito é o **id inteiro simples** da sprint, não o array/objeto.
  Ex.: `{"customfield_10010": 4413}`. Peculiaridade real do Jira Cloud, não
  bug do MCP.
- Story points: `customfield_10092` ("Story point estimate"), número
  simples, mesmo formato em get e set.
- Vínculo a Épico: campo `parent`, valor um **objeto** `{"key": "DOPS-XXX"}`
  — string simples dá erro "data was not an object".
