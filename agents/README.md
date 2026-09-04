# Agents

Subagentes do Claude Code (`.claude/agents/*.md`) — diferente de `skills/`, cada agent é **um único arquivo Markdown** com frontmatter (`name`, `description`, `tools`, opcionalmente `model`), sem pasta própria nem `references/`.

Esta pasta ainda não tem nenhum agent real — é o esqueleto para quando um caso concreto justificar um. Ao adicionar o primeiro, espelhar a mecânica já usada por `rules/` no `playbook.yml` (task `file` garantindo `~/.claude/agents/` + `copy`/`with_fileglob` de `agents/*.md` para lá, excluindo este README do glob).

## Candidato observado

**Agent de hardening/validação de infra** — encapsularia o loop *investigar → reportar → aguardar autorização → aplicar* já registrado em `rules/execution-caution.md` como um procedimento repetível para ciclos de validação recorrente em servidor (ex.: varredura diária de hardening pós-incidente num conjunto fixo de hosts). Vale a pena promover a agent quando esse tipo de ciclo diário voltar a se repetir por vários dias seguidos no mesmo escopo — até lá, a regra solta em `rules/` já cobre o comportamento.

Nenhum outro tema revisado em `behaviors-review/` (triagem de 2026-09) apontou claramente para um segundo agent — os demais encaixaram melhor em `rules/` ou em refinamento de skill existente.
