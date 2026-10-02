---
name: incident-triage
description: Análise inicial só leitura de um incidente de servidor a partir de um card do Jira criado pelo Zabbix, com hipóteses, evidências e um plano sugerido postado direto no card de origem. Gatilho manual — a chamada da skill é a permissão para comentar. Use quando o usuário disser "triagem do DOPS-XXX", "analisa esse alerta", "começa a investigação desse card", ou passar a chave de um card de alerta Zabbix pedindo análise inicial. Não aplica nenhuma mudança em servidor nem cria subtasks (isso é incident-plan-refine).
---

# Incident Triage

Primeira fase do agente `analista-de-incidentes`. Sem travas de aprovação
no meio: lê, analisa, posta. Mas é só leitura — nada é alterado em servidor
e nada além de um comentário é escrito no Jira.

## Passo 1: Ler o card de origem

`getJiraIssue` na chave informada, com comentários. Extraia host, trigger,
severidade, horário do evento e se já houve recovery. O summary segue
`[Zabbix] {HOST.NAME} — {EVENT.NAME}`. Se já existir um comentário
`[Incidente] Fase: Triagem`, avise o usuário e pergunte se é para refazer
antes de continuar.

## Passo 2: Coletar contexto anterior

- Outros cards do mesmo host: JQL `project = DOPS AND summary ~ "<host>"
  ORDER BY created DESC` (últimos ~10).
- Diagnósticos anteriores no vault (só leitura): `search_vault`/
  `search_content` pelo host e pelo sintoma em `39_Diagnostics/`.
- Memória da sessão sobre o host, se houver.

## Passo 3: Investigar no servidor (só leitura)

Acesso via jumphost. Apenas comandos de leitura: `uptime`, `df -h`,
`free -m`, `top -bn1`, `systemctl status`, `journalctl`, `tail` de logs,
`ss -tlnp`, `cat` de config, `getent hosts` etc. Nenhum comando que altere
estado — nem limpeza "óbvia", nem restart. Se o host não for acessível,
registre isso como pendência e siga com o que tiver.

## Passo 4: Montar análise e plano sugerido

- Hipóteses ordenadas por probabilidade, cada uma com a evidência que a
  sustenta ou enfraquece.
- Impacto aparente (o que está fora/degradado, para quem).
- Plano sugerido: sequência curta de etapas, da mais segura para a mais
  arriscada, indicando o que é diagnóstico e o que é mudança (mudança é
  sempre executada pelo usuário).
- O que falta saber para fechar a causa raiz.

## Passo 5: Postar no card

Via skill `incident-comment`, fase `Triagem`, postando direto — a chamada
manual desta skill já é a permissão. Mostre ao usuário o mesmo conteúdo e
o link do comentário, e sugira seguir com `incident-plan-refine`.
