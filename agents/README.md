# Agents

Subagentes do Claude Code (`.claude/agents/*.md`) — diferente de `skills/`, cada agent é **um único arquivo Markdown** com frontmatter (`name`, `description`, `tools`, opcionalmente `model`), sem pasta própria nem `references/`.

O `playbook.yml` copia todo `agents/*.md` para `~/.claude/agents/`, **exceto este README** (task `find` com `excludes: "README.md"` + `copy`, mesma mecânica de `rules/*.md`). Para adicionar um agent novo: soltar o arquivo aqui e rodar `tk-setup` — nenhuma edição no playbook é necessária.

## Agent ativo: agente-backoffice

Cria e padroniza tickets no DOPS — ver `agente-backoffice.md`. Automático,
sem aprovação, só para clone/espelho (`glpi-radar`, `jira-radar`), rodando
no cron de hora em hora, 10h–17h dos dias úteis. Manual e com aprovação explícita
para `jira-ticket-creator` (pedido novo) e `jira-sprint` (sprint).

## Agent ativo: agente-consultor

Avaliador do dia a dia — ver `agente-consultor.md`. Só organiza e sugere:
`email-triage` (labels `IA/*`, de hora em hora 08h–18h), `daily-brief`
(mensagem no Google Chat via webhook, rascunho no Gmail se falhar; tentado de hora em hora 09h–12h até sair o do dia), `email-rules-suggest` (sexta
16:30) e `jira-saude` (leitura). Única escrita: labels `IA/*` e rascunhos
para o próprio usuário (envio é bloqueado pelo admin).

## Agendamento

`playbook.yml` instala o crontab chamando `cron/run-agent.sh <agente>
<prompt>`, que roda `claude -p --agent <agente> --permission-mode dontAsk`
liberando só as tools do frontmatter do agente (o `Bash` do backoffice vira
só o script do `glpi-radar`). Log por agente em `~/workspace/temp/cron/`.

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
