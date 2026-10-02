# Agents

Subagentes do Claude Code (`.claude/agents/*.md`) — diferente de `skills/`, cada agent é **um único arquivo Markdown** com frontmatter (`name`, `description`, `tools`, opcionalmente `model`), sem pasta própria nem `references/`.

O `playbook.yml` copia todo `agents/*.md` para `~/.claude/agents/`, **exceto este README** (task `find` com `excludes: "README.md"` + `copy`, mesma mecânica de `rules/*.md`). Para adicionar um agent novo: soltar o arquivo aqui e rodar `tk-setup` — nenhuma edição no playbook é necessária.

## Agent ativo: orquestrador-de-tickets

Persona de triagem entre `jira-ticket-creator` (pedido novo) e `jira-radar`
(varredura de órfãos fora do DOPS, montagem de sprint, tickets estagnados,
sincronia de espelhos) — ver `orquestrador-de-tickets.md` neste diretório.
Não redefine convenções, só decide qual skill invocar e garante o gate de
aprovação explícita.

## Agent ativo: analista-de-incidentes

Persona de triagem e acompanhamento de incidentes de servidor a partir de
um card já criado pelo Zabbix (DOPS-207) — ver `analista-de-incidentes.md`.
Três fases: inicial (`incident-triage` → `incident-plan-refine`, etapas do
plano final viram subtasks do card), execução (loop de acompanhamento e
validação) e finalização (`incident-postmortem` → `diagnostic-creator`,
`.md` na pasta `post-mortem` do Drive). Todo registro vai como comentário
no card via `incident-comment`; nada é escrito no vault. Servidor só em
leitura — escrita é sempre do usuário. Uso recomendado como persona da
sessão principal: `claude --agent analista-de-incidentes`.

## Outro candidato observado (ainda não promovido)

**Agent de hardening/validação de infra** — encapsularia o loop *investigar → reportar → aguardar autorização → aplicar* já registrado em `rules/execution-caution.md` como um procedimento repetível para ciclos de validação recorrente em servidor (ex.: varredura diária de hardening pós-incidente num conjunto fixo de hosts). Vale a pena promover a agent quando esse tipo de ciclo diário voltar a se repetir por vários dias seguidos no mesmo escopo — até lá, a regra solta em `rules/` já cobre o comportamento.

Nenhum outro tema revisado em `behaviors-review/` (triagem de 2026-09) apontou claramente para um segundo agent — os demais encaixaram melhor em `rules/` ou em refinamento de skill existente.
