---
name: jira-radar
description: Varre o Jira periodicamente por quatro ângulos — (1) issues assignadas ao usuário fora do projeto DOPS que ainda não têm nenhum Linked Work Item DOPS-*, (2) backlog do DOPS sem sprint atribuída, para ajudar a montar a sprint da semana, (3) issues do DOPS sem atualização há vários dias (estagnadas), e (4) issues-espelho do DOPS cuja issue original já foi concluída, candidatas a fechar. Propõe em tabela ou lista, nunca escreve sem aprovação explícita quando o modo envolve criar/editar. Usa as mesmas convenções de Épico, formato de descrição e aprovação da skill jira-ticket-creator — não as redefine. Use quando o usuário disser "roda o radar", "vê o que tá sem ticket no DOPS", "monta a sprint", "o que entra na sprint dessa semana", "backlog do DOPS", "tickets parados/estagnados", "os espelhos já podem fechar", ou periodicamente a pedido dele. Não use para formalizar um pedido novo que acabou de chegar (isso é jira-ticket-creator).
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

## Modo 2 — Montagem da sprint da semana

### Buscar candidatos de backlog

JQL:
```
project = DOPS AND sprint is EMPTY AND statusCategory != Done ORDER BY priority DESC, created ASC
```

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

Levantado em 2026-09-11 somando `customfield_10092` das issues concluídas
em cada sprint fechada, atribuídas pela **data de conclusão
(`resolutiondate`) dentro da janela `startDate`/`endDate` da sprint** —
não pela simples presença no array de `customfield_10010`, que guarda todo
o histórico de sprints por onde a issue passou (usar `sprint = X` na JQL
conta issues retrabalhadas em mais de uma sprint em dobro).

- SPRINT 6 (18/08–25/08): 21 SP entregues (piso — 5 issues concluídas
  nessa sprint não tinham estimativa, contam como 0).
- SPRINT 7 (25/08–01/09): 55 SP entregues.
- SPRINT 8 (01/09–08/09): 16 SP entregues.
- Média das últimas 3 sprints fechadas: ≈31 SP. Média das últimas 2: ≈35,5
  SP.

Isto é só uma nota de contexto — o usuário decidiu não ter cálculo de
capacidade automático neste modo, a decisão de quanto entra na sprint
continua sendo dele. Ao usar este modo, vale citar essa referência e
sugerir recalcular com as sprints mais recentes à medida que mais dados
forem se acumulando, em vez de tratar os três números acima como
permanentes.

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

- O MCP Atlassian ativo nesta conta usa prefixo `mcp__claude_ai_Atlassian__*`
  (busca por JQL, leitura/criação/edição de issue, criação de link,
  `getAccessibleAtlassianResources` para obter o cloudId
  `idealtrends.atlassian.net`). **Não é o mesmo MCP** que
  `jira-ticket-creator` documenta como `mcp:jira` com tools `jira_*`
  (incluindo ferramentas de agile board/sprint) — esse MCP antigo não está
  disponível aqui. Já houve um drift silencioso de nome de MCP uma vez; se
  acontecer de novo, procure no MCP ativo o equivalente antes de assumir que
  o Jira caiu.
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
