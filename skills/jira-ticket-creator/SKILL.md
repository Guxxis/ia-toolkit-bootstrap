---
name: jira-ticket-creator
description: Formaliza uma solicitação de trabalho — boca a boca, GLPI, incidente de servidor/sistema, ou necessidade de provisionar/configurar servidor ou sistema — como uma issue rastreável no Jira (projeto DOPS), passando por brainstorm, proposta em tabela, refinamento e aprovação explícita antes de escrever qualquer coisa. A issue cai em um de três Épicos guarda-chuva conforme a natureza do pedido — Incidentes de Servidor/Sistema (DOPS-207), Provisionamento (DOPS-208) ou Tickets/Chamados (DOPS-156) — decidido durante a conversa, não fixo. Use sempre que o usuário colar um chamado GLPI, relatar um pedido de trabalho boca a boca, descrever um problema em servidor/sistema, pedir para subir/configurar um novo servidor ou sistema, ou disser "formalizar isso no Jira", "registrar esse chamado", "cria uma tarefa/ticket pra isso", "documentar essa demanda". Não use para diagnóstico técnico pós-incidente já resolvido (isso é a skill diagnostic-creator) nem para planejamento completo de infraestrutura de projeto novo (isso é a skill infra-planner) — esta skill é a triagem e formalização do pedido em si.
---

# Jira Ticket Creator

Skill para transformar uma solicitação que hoje só existe em conversa, GLPI, ou relato de problema em uma issue rastreável no Jira, projeto **DOPS**.

## Regras fixas, sem exceção

- **Projeto sempre `DOPS`, nunca o board do produto/sistema afetado.** Mesmo quando o pedido é sobre outro sistema (IdealTrack/IT, Auditoria/AI, etc.), a issue é registrada em DOPS — o board do produto é dos times de desenvolvimento daquele produto, não do time de infra.
- **Tipo da issue segue o Épico: `Problema` (Incidentes), `História` (Provisionamento), `Tarefa` (Tickets/Chamados).** Ver tabela de destino abaixo.
- **Sempre vinculada a um dos três Épicos via campo `parent`.** Não existe issue solta fora de Épico neste fluxo.
- **Nada vai para o Jira sem aprovação explícita da proposta.** Colar contexto ou pedir para "formalizar" autoriza **montar** a proposta — não publicá-la. Silêncio não é aprovação.

Depois de criada, a issue é do usuário: transições de status, comentários de andamento e fechamento são feitos por ele — esta skill só cria e relata.

## Épicos de destino

A decisão de qual Épico usar é feita durante a conversa (Etapa Brainstorm/Proposta), não é assumida de antemão:

| Categoria | Épico | Tipo da issue | Quando usar |
|---|---|---|---|
| **Incidente** | DOPS-207 "Incidentes de Servidor/Sistema" | `Problema` | Já aconteceu ou está acontecendo um problema em servidor/sistema (queda, erro, degradação, falha) |
| **Provisionamento** | DOPS-208 "Provisionamento" | `História` | Subir ou configurar um servidor/sistema novo, migrar ambiente para nova infra |
| **Tickets/Chamados** | DOPS-156 "Tickets/Chamados" | `Tarefa` | Qualquer outro pedido de trabalho — o catch-all (pipeline, investigação, acesso, config pontual) |

**Na dúvida sobre qual dos três se aplica, pergunte — não assuma.** Melhor uma pergunta a mais no Brainstorm do que uma issue no Épico errado.

Se surgir uma categoria nova e recorrente que não se encaixa nos três, é válido propor um Épico dedicado (como aconteceu com Incidentes e Provisionamento) — trate isso como uma decisão a confirmar com o usuário, não como uma quarta opção implícita.

## O fluxo: Brainstorm → Proposta → Refinamento → Aprovação → Aplicação

Nenhuma etapa escreve no Jira antes da Aprovação. Cada etapa só avança quando a anterior está resolvida.

### 1. Brainstorm

Releia o que o usuário colou/descreveu ou o que motivou a ativação da skill e extraia o que já está disponível:

- **O que está sendo pedido** — o pedido em si, não a solução
- **Categoria aparente** — Incidente / Provisionamento / Ticket (se não estiver óbvio, é isso que você pergunta)
- **Quem pediu, canal de origem** (boca a boca / GLPI #número), sistema/domínio afetado, urgência

Pergunte tudo que falta **em uma única mensagem, texto corrido** (não use múltiplas rodadas nem `AskUserQuestion` aqui — as respostas são abertas):

- Categoria, se ambígua
- **Urgência, de 1 a 5** (1 = mais baixa, 5 = mais alta) — mapeia direto para a prioridade do Jira (ver tabela "Urgência → prioridade Jira" na Aplicação)
- Prazo / data limite
- Esforço em Story Points (`customfield_10092`) — não usamos mais horas/dias
- Responsável — assume o próprio usuário por padrão; só pergunte se houver sinal de que deveria ficar com outra pessoa
- Sprint pretendida (ou "backlog, sem sprint")
- Contexto adicional, se o pedido for vago demais para virar issue acionável

Não insista em campos que o usuário claramente não sabe responder ainda ("infra ainda não decidida" é resposta válida, não lacuna a cobrar de novo).

Nesta etapa, verifique também se já existe uma issue relacionada:

```
searchJiraIssuesUsingJql(
  cloudId: "idealtrends.atlassian.net",
  jql: "project = DOPS AND text ~ \"<sistema ou palavra-chave>\" ORDER BY created DESC",
  fields: ["summary", "status", "issuetype"]
)
```

Se encontrar uma issue claramente correspondente, a proposta da próxima etapa deve sugerir **linkar** em vez de criar (ver "Aplicação alternativa" no fim).

Se algum item vai ter Sprint atribuída, descubra a sprint real antes de propor qualquer nome/id — via JQL `project = DOPS AND sprint in openSprints()` (ou `futureSprints()` se não houver ativa), lendo `customfield_10010` do resultado com `view: "full"`: é um array `{id, name, state, ...}`, o de `state: "active"` é a sprint ativa.

Nunca invente nome ou id de sprint — use o que veio do Jira.

> **Nota para o futuro:** quando existirem POPs documentados, esta etapa poderá consultá-los para sugerir esforço/prioridade/responsável por tipo de solicitação. Por enquanto isso é decisão só do usuário.

### 2. Proposta

Monte e apresente uma **tabela consolidada** com todas as issues que seriam criadas, antes de tocar no Jira:

| Coluna | Conteúdo |
|---|---|
| Issue/Título | resumo curto |
| Categoria/Épico | Incidente (DOPS-207) / Provisionamento (DOPS-208) / Tickets (DOPS-156) — ou épico já existente |
| Urgência | 1 a 5 (prioridade Jira correspondente entre parênteses, ex. "4 (Alta)") |
| Sprint | nome real da sprint (ou "Backlog, sem sprint") |
| Prazo | data ou "sem prazo definido" |
| Esforço | N SP |
| Responsável | pessoa |

Liste também as **subtarefas propostas** por issue (passos concretos de execução), já quebradas nesta etapa — não deixe para depois.

Se alguma issue já existe (achada no Brainstorm), marque: "isso já existe como `<chave>` — vou linkar em vez de criar".

### 3. Refinamento

O usuário ajusta a proposta (muda esforço, prazo, categoria, adiciona/remove subtarefa, etc.). Atualize a tabela e reapresente só o que mudou — não repita a tabela inteira se a mudança for pequena, mas deixe claro o estado final.

### 4. Aprovação

Pergunte, em uma única mensagem, se pode criar — a menos que o usuário já tenha aprovado explicitamente item a item (ex: "1. ok, 2. ok..."). Nunca assuma aprovação por silêncio ou por o usuário ter só pedido para "formalizar".

### 5. Aplicação

Só aqui se escreve no Jira. Ordem: Épico (se ainda não existir) → Histórias/Problemas → Sprint → Subtarefas → confirmação.

**Descrição** — sempre em markdown (nunca wiki markup), nesta estrutura:

```markdown
## Pedido

<o que está sendo solicitado, 2-4 linhas>

## Origem

- Solicitante: <pessoa/área/empresa>
- Canal: Boca a boca | GLPI #<número> (<link, se houver>)
- Sistema/domínio: <se aplicável>

## Contexto adicional

<qualquer detalhe extra relevante coletado no Brainstorm>
```

**MCP:** usar o conector "Atlassian MCP" (`mcp__claude_ai_Atlassian_MCP__*`), com `cloudId: "idealtrends.atlassian.net"` em toda chamada. O conector "Atlassian" (`mcp__claude_ai_Atlassian__*`) responde 403 "app is not installed", e o antigo `mcp:jira`/`jira_*` não existe mais. Operações sem tool primária (ex. `createJiraIssueLink`) rodam via `discover` → `executeWrite`.

**Nunca use `**negrito**` na descrição** — o MCP Jira corrompe o marcador de fechamento no round-trip markdown↔wiki (`**Solicitante:**` vira `**Solicitante:*`). `##` e `-` funcionam normalmente; para destacar um rótulo use dois-pontos simples (`Solicitante: valor`).

**Criação da issue:**

```
createJiraIssue(
  cloudId: "idealtrends.atlassian.net",
  projectKey: "DOPS",
  summary: "<resumo curto do pedido>",
  issueType: "Problema" | "História" | "Tarefa",   // conforme o Épico — ver tabela acima
  parent: "<DOPS-156|DOPS-207|DOPS-208>",
  description: <descrição montada acima>,
  assignee: "<accountId do responsável>",           // o próprio usuário: atlassianUserInfo
  additional_fields: {"customfield_10092": <SP>, "priority": {"id": "<id>"}, "duedate": "<YYYY-MM-DD>"}
)
```

`duedate` só se houver prazo. Esforço vai sempre em Story Points no `customfield_10092` (número simples) — não usar `timetracking`.

**Urgência → prioridade Jira:** a urgência 1-5 coletada no Brainstorm vira `priority` **pelo `id`**. Os nomes nesta instância são em português e "Média " tem espaço no final — `name` em inglês (Medium/High…) é rejeitado com "prioridade selecionada é inválida".

| Urgência | `priority.id` | Nome no Jira |
|---|---|---|
| 5 | 1 | Muito Alta |
| 4 | 2 | Alta |
| 3 | 3 | Média |
| 2 | 4 | Baixa |
| 1 | 5 | não confirmado (nenhuma issue usa) — validar na primeira vez |

**Vínculo ao Épico:** neste projeto (team-managed/next-gen), o vínculo Épico↔issue é feito pelo campo `parent`, **não** por `epicKey`/`epic_link` (esbarra em `customfield_10008 cannot be set`). Se estiver **convertendo** uma issue já existente em vez de criar uma nova:

```
editJiraIssue(cloudId: "idealtrends.atlassian.net", issueIdOrKey: "<chave>", fields: {"parent": {"key": "<épico>"}})
```

**Sprint:** se houver uma definida na proposta, setar `customfield_10010` com o **id inteiro** da sprint (não o array/objeto que vem na leitura) — direto no `additional_fields` da criação ou depois via `editJiraIssue`: `{"customfield_10010": <id>}`.

**Subtarefas** (já definidas na Proposta/Refinamento, não inventadas aqui):

```
createJiraIssue(
  cloudId: "idealtrends.atlassian.net",
  projectKey: "DOPS",
  summary: "<passo concreto>",
  issueType: "Subtarefa",
  parent: "<chave da issue-pai>",
  assignee: "<accountId do responsável>"
)
```

**Aplicação alternativa — issue já existente:** em vez de criar, linke a solicitação à issue encontrada no Brainstorm:

```
executeWrite(
  cloudId: "idealtrends.atlassian.net",
  name: "createJiraIssueLink",
  inputs: {"linkType": "Relates", "inwardIssue": "<chave existente>", "outwardIssue": "<outra chave>"}
)
```

Registre em comentário (`addOrEditJiraIssueComment`) que é uma nova ocorrência/solicitação do mesmo pedido, com origem e quem pediu desta vez.

**Confirme ao final:**

- Chave e link de cada issue criada (`https://idealtrends.atlassian.net/browse/<chave>`) — ou da issue existente linkada
- Épico, urgência (com a prioridade Jira correspondente), sprint, prazo, esforço (SP) e responsável registrados — relendo a issue com `getJiraIssue` (`view: "full"`), não só pela resposta da criação
- Se alguma etapa falhou, avise explicitamente em vez de reportar sucesso parcial como sucesso total
