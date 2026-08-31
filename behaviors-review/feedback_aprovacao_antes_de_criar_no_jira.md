---
name: feedback_aprovacao_antes_de_criar_no_jira
description: Nunca criar issue/subtarefa no Jira sem aprovação explícita do que exatamente será criado
metadata: 
  node_type: memory
  type: feedback
  originSessionId: cfb2a166-8f21-45af-8ae6-2ec7f32ae86c
  modified: 2026-08-03T20:09:34.673Z
---

Não criar, transicionar ou excluir nada no Jira sem o usuário aprovar antes **o que exatamente** vai ser criado. Em 03/08/2026 a skill `diagnostic-creator` gerou 1 issue + 11 subtarefas de uma vez no DOPS; o usuário considerou "sem necessidade ou validação" e mandou excluir 7 delas.

**Why:** o Jira é ferramenta compartilhada — ticket criado vira cobrança de trabalho para outras pessoas e polui o backlog. Pedir para "documentar" ou "criar diagnóstico" autoriza **produzir** o diagnóstico, não povoar o backlog. E investigação boa costuma achar mais problema do que o time quer rastrear: decidir o que entra é do usuário.

**How to apply:** entregar primeiro o diagnóstico e o artefato HTML, depois listar em uma mensagem o que *seria* criado (título + severidade da issue, uma linha por subtarefa candidata com a área) e perguntar o que registrar: tudo, um subconjunto, só a principal, ou nada. Silêncio não é aprovação. Aprovar a issue principal não aprova as subtarefas. O que não for aprovado fica só no artefato — não reabrir o assunto depois.

Regra já embutida no `SKILL.md` da `diagnostic-creator` (seção "Regra que precede todas as outras" + Passo 6).

Relacionado: [[feedback_jira_status_updates_pelo_usuario]], [[reference_diagnostic_creator_jira]], [[feedback_git_commits]], [[feedback_cosmetico_baixa_prioridade]]
