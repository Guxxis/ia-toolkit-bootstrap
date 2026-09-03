---
name: jira-ticket-creator
description: Formaliza uma solicitação de trabalho — boca a boca, GLPI, incidente de servidor/sistema, ou necessidade de provisionar/configurar servidor ou sistema — como uma issue rastreável no Jira (projeto DOPS), passando por brainstorm, proposta em tabela, refinamento e aprovação explícita antes de escrever qualquer coisa. A issue cai em um de três Épicos guarda-chuva conforme a natureza do pedido — Incidentes de Servidor/Sistema (DOPS-207), Provisionamento (DOPS-208) ou Tickets/Chamados (DOPS-156) — decidido durante a conversa, não fixo. Use sempre que o usuário colar um chamado GLPI, relatar um pedido de trabalho boca a boca, descrever um problema em servidor/sistema, pedir para subir/configurar um novo servidor ou sistema, ou disser "formalizar isso no Jira", "registrar esse chamado", "cria uma tarefa/ticket pra isso", "documentar essa demanda". Não use para diagnóstico técnico pós-incidente já resolvido (isso é a skill diagnostic-creator) nem para planejamento completo de infraestrutura de projeto novo (isso é a skill infra-planner) — esta skill é a triagem e formalização do pedido em si.
---

# Jira Ticket Creator

Skill para transformar uma solicitação que hoje só existe em conversa, GLPI, ou relato de problema em uma issue rastreável no Jira, projeto **DOPS**.

## Regras fixas, sem exceção

- **Projeto sempre `DOPS`, nunca o board do produto/sistema afetado.** Mesmo quando o pedido é sobre outro sistema (IdealTrack/IT, Auditoria/AI, etc.), a issue é registrada em DOPS — o board do produto é dos times de desenvolvimento daquele produto, não do time de infra.
- **Tipo `História` por padrão; `Problema` quando cai no Épico Incidentes.** Ver tabela de destino abaixo — é o único caso em que o tipo muda.
- **Sempre vinculada a um dos três Épicos via campo `parent`.** Não existe issue solta fora de Épico neste fluxo.
- **Nada vai para o Jira sem aprovação explícita da proposta.** Colar contexto ou pedir para "formalizar" autoriza **montar** a proposta — não publicá-la. Silêncio não é aprovação.

Depois de criada, a issue é do usuário: transições de status, comentários de andamento e fechamento são feitos por ele — esta skill só cria e relata.

## Épicos de destino

A decisão de qual Épico usar é feita durante a conversa (Etapa Brainstorm/Proposta), não é assumida de antemão:

| Categoria | Épico | Tipo da issue | Quando usar |
|---|---|---|---|
| **Incidente** | DOPS-207 "Incidentes de Servidor/Sistema" | `Problema` | Já aconteceu ou está acontecendo um problema em servidor/sistema (queda, erro, degradação, falha) |
| **Provisionamento** | DOPS-208 "Provisionamento" | `História` | Subir ou configurar um servidor/sistema novo, migrar ambiente para nova infra |
| **Tickets/Chamados** | DOPS-156 "Tickets/Chamados" | `História` | Qualquer outro pedido de trabalho — o catch-all (pipeline, investigação, acesso, config pontual) |

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
- Prazo / data limite
- Esforço estimado (horas ou dias)
- Responsável — assume o próprio usuário por padrão; só pergunte se houver sinal de que deveria ficar com outra pessoa
- Sprint pretendida (ou "backlog, sem sprint")
- Contexto adicional, se o pedido for vago demais para virar issue acionável

Não insista em campos que o usuário claramente não sabe responder ainda ("infra ainda não decidida" é resposta válida, não lacuna a cobrar de novo).

Nesta etapa, verifique também se já existe uma issue relacionada:

```
mcp:jira → jira_search(
  jql: "project = DOPS AND text ~ \"<sistema ou palavra-chave>\" ORDER BY created DESC",
  fields: "summary,status,issuetype"
)
```

Se encontrar uma issue claramente correspondente, a proposta da próxima etapa deve sugerir **linkar** em vez de criar (ver "Aplicação alternativa" no fim).

Se algum item vai ter Sprint atribuída, busque as sprints reais do board antes de propor qualquer nome/id:

```
mcp:jira → jira_get_agile_boards(project_key: "DOPS")
mcp:jira → jira_get_sprints_from_board(board_id: "<id do board>")
```

Nunca invente nome ou id de sprint — use o que veio do board.

> **Nota para o futuro:** quando existirem POPs documentados, esta etapa poderá consultá-los para sugerir esforço/prioridade/responsável por tipo de solicitação. Por enquanto isso é decisão só do usuário.

### 2. Proposta

Monte e apresente uma **tabela consolidada** com todas as issues que seriam criadas, antes de tocar no Jira:

| Coluna | Conteúdo |
|---|---|
| Issue/Título | resumo curto |
| Categoria/Épico | Incidente (DOPS-207) / Provisionamento (DOPS-208) / Tickets (DOPS-156) — ou épico já existente |
| Sprint | nome real da sprint (ou "Backlog, sem sprint") |
| Prazo | data ou "sem prazo definido" |
| Esforço | horas/dias |
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

**Nunca use `**negrito**` na descrição** — o MCP Jira corrompe o marcador de fechamento no round-trip markdown↔wiki (`**Solicitante:**` vira `**Solicitante:*`). `##` e `-` funcionam normalmente; para destacar um rótulo use dois-pontos simples (`Solicitante: valor`).

**Criação da issue:**

```
mcp:jira → jira_create_issue(
  project_key: "DOPS",
  summary: "<resumo curto do pedido>",
  issue_type: "História" | "Problema",   // Problema só quando Épico = Incidentes
  description: <descrição montada acima>,
  assignee: "<email do responsável>",
  additional_fields: '{"parent": "<DOPS-156|DOPS-207|DOPS-208>", "duedate": "<YYYY-MM-DD>", "timetracking": {"originalEstimate": "<N>h ou <N>d"}}'
)
```

**Vínculo ao Épico:** neste projeto (team-managed/next-gen), o vínculo Épico↔issue é feito pelo campo `parent`, **não** por `epicKey`/`epic_link` nem por `jira_link_to_epic` — ambos falham aqui (`epicKey` esbarra em `customfield_10008 cannot be set`; `jira_link_to_epic` retorna "não é um Épico" mesmo sendo um, provavelmente por checar o nome do tipo em inglês). Se estiver **convertendo** uma issue já existente em vez de criar uma nova:

```
mcp:jira → jira_update_issue(issue_key: "<chave>", fields: '{"parent": "<épico>"}')
```

**Sprint:** depois de criada a issue, atribua a sprint (se houver uma definida na proposta):

```
mcp:jira → jira_add_issues_to_sprint(sprint_id: "<id real do board>", issue_keys: "<chave1>,<chave2>,...")
```

**Subtarefas** (já definidas na Proposta/Refinamento, não inventadas aqui):

```
mcp:jira → jira_create_issue(
  project_key: "DOPS",
  summary: "<passo concreto>",
  issue_type: "Subtarefa",
  additional_fields: '{"parent": "<chave da issue-pai>"}'
)
```

**Aplicação alternativa — issue já existente:** em vez de criar, linke a solicitação à issue encontrada no Brainstorm:

```
mcp:jira → jira_create_issue_link(link_type: "Relates", inward_issue_key: "<chave existente>", outward_issue_key: "<chave existente>")
```

Registre em comentário (`jira_add_comment`) que é uma nova ocorrência/solicitação do mesmo pedido, com origem e quem pediu desta vez.

**Confirme ao final:**

- Chave e link de cada issue criada (`https://idealtrends.atlassian.net/browse/<chave>`) — ou da issue existente linkada
- Épico, sprint, prazo, esforço e responsável registrados
- Se alguma etapa falhou, avise explicitamente em vez de reportar sucesso parcial como sucesso total
