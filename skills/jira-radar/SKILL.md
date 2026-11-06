---
name: jira-radar
description: Radar de órfãos do Jira — busca issues assignadas ao usuário fora do projeto DOPS que ainda não têm nenhum Linked Work Item DOPS-* e cria automaticamente, sem aprovação, o card espelho no DOPS. Pensado para rodar agendado (cron do agente-backoffice), junto com glpi-radar. Use quando o usuário disser "roda o radar", "vê o que tá sem ticket no DOPS", "tem coisa minha fora do DOPS sem espelho". Não use para montar sprint (isso é jira-sprint), para tickets estagnados ou espelhos a fechar (isso é jira-saude), nem para formalizar um pedido novo (isso é jira-ticket-creator).
---

# Jira Radar (órfãos fora do DOPS)

## Relação com jira-ticket-creator (não duplicar)

Esta skill **não redefine** nada que já está fixado em `jira-ticket-creator`:
tabela de Épicos, formato de descrição (Pedido/Origem/Contexto adicional),
proibição de `**negrito**` na descrição. Antes de criar qualquer issue,
releia `skills/jira-ticket-creator/SKILL.md` (seções "Épicos de destino" e
"Aplicação") e siga o que estiver lá. Se um dia esta skill e aquela
divergirem, a fonte de verdade é `jira-ticket-creator` — ajuste este
arquivo, não o contrário.

**Exceção deliberada:** esta skill não passa pelo gate de aprovação — o
usuário decidiu que todo item aberto atribuído a ele fora do DOPS vira
espelho automaticamente, para o radar poder rodar agendado. Ela só cria
espelho e link; nunca edita, comenta, transiciona ou mexe em sprint.

## Buscar candidatos

JQL:
```
assignee = currentUser() AND project != DOPS AND statusCategory != Done
```
via a ferramenta de busca JQL do MCP Atlassian ativo, com `view: "full"` e
os campos `summary`, `issuetype`, `priority`, `reporter`, `description`,
`issuelinks` e `customfield_10092` — tudo que a criação do espelho usa.

## Filtrar

Descarte qualquer issue cujos `issuelinks` já apontem para uma chave
`DOPS-*` (inward ou outward, qualquer tipo de link — já tem rastreio, não
duplicar). O que resta são os órfãos.

Antes de criar, procure também por espelho já existente sem link (rodada
anterior que criou a issue mas falhou no link):
```
project = DOPS AND summary ~ "\"[<CHAVE-ORIGINAL>]\""
```
Se achar, não crie outro — só crie o link `Relates` que está faltando.

**Limitação conhecida:** um link remoto (URL colada em vez de link Jira
nativo) para uma issue DOPS não é pego por nenhum dos dois filtros — pior
caso é um espelho duplicado, que o usuário fecha à mão.

## Criar o espelho (automático, sem aprovação)

Para cada órfão, sem perguntar nada:

- Título: `[<CHAVE-ORIGINAL>] <summary original>` — ex. `[AI-641] WildCard
  não funcionando em Produção Projeto Auditoria`. Não usar o prefixo
  `[Espelho <CHAVE>]` (formato antigo).
- Responsável: o próprio usuário (`assignee` = accountId do
  `atlassianUserInfo`).
- Sprint: nenhuma — vai para o backlog; o usuário puxa via `jira-sprint`.
- Épico (`parent` como objeto, ver "Descobertas técnicas"): original do tipo
  Problema/Bug → DOPS-207 com tipo `Problema`; qualquer outro tipo →
  DOPS-156 com tipo `Tarefa`. Nunca DOPS-208 automaticamente — o usuário
  move para Provisionamento à mão quando for o caso.
- Prioridade: o `id` da prioridade da original (ids são os mesmos em todos
  os projetos da instância); se a original não tiver, `3` (Média).
- Story points: copiar `customfield_10092` da original só se estiver
  preenchido (mesmo campo em todos os projetos).
- Descrição: formato Pedido/Origem/Contexto adicional de
  `jira-ticket-creator`. Pedido = summary + início da descrição da original
  (resumida, 2-4 linhas; "sem descrição na original" se vazia). Origem =
  reporter da original como solicitante, canal `Jira <CHAVE> (<link>)`,
  projeto como sistema.
- Link: `createJiraIssueLink` tipo `Relates`, `inwardIssue` = espelho,
  `outwardIssue` = original. Se falhar, não tente de novo na mesma rodada —
  o filtro por título da próxima rodada completa o link.

## Relatório

Termine com uma lista curta: para cada espelho criado, chave nova, chave
original, título e Épico; links que falharam; ou "nenhum órfão novo" quando
não houver nada. Nada além disso — a rodada é para ser silenciosa.

## Descobertas técnicas (instância idealtrends.atlassian.net, projeto DOPS)

> Válidas em 2026-09. Se algo aqui parar de funcionar, revalidar antes de
> assumir que o código/JQL está errado — a causa mais provável é a
> instância ter mudado (reprojetar board, reconfigurar campo), não a skill.
> `glpi-radar`, `jira-sprint` e `jira-saude` apontam para esta seção.

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
  campo, o que faria todo issue parecer órfão.
- Prioridade: setar pelo `id` (1 Muito Alta, 2 Alta, 3 Média, 4 Baixa) —
  ver tabela em `jira-ticket-creator`; `name` em inglês é rejeitado.
- Story points: `customfield_10092` ("Story point estimate"), número
  simples, mesmo formato em get e set.
- Vínculo a Épico: campo `parent`, valor um **objeto** `{"key": "DOPS-XXX"}`
  — string simples dá erro "data was not an object".
