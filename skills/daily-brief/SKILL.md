---
name: daily-brief
description: Monta e deixa como rascunho no Gmail, endereçado ao próprio usuário, o briefing do dia útil — agenda do dia, e-mails que pedem ação, cards do DOPS na sprint, chamados GLPI/espelhos novos e espelhos a fechar — terminando com o foco do dia; às segundas inclui a visão da semana (agenda, fim da sprint, estagnados). Só lê, a única escrita é o rascunho. Roda de hora em hora das 09h às 12h no cron do agente-consultor (só cria se ainda não houver o do dia) e sob demanda quando o usuário disser "me dá o briefing", "o que eu foco hoje", "resumo da semana".
---

# Daily Brief

Fontes: Gmail (labels da `email-triage`), Google Calendar, Jira via
`jira-saude` e buscas JQL próprias (conector e `view: "full"`: ver
"Descobertas técnicas" de `jira-radar`). Os chamados GLPI entram pelos
cards `[GLPI #<id>]` que o `agente-backoffice` cria no DOPS — esta skill não
acessa o GLPI.

## 0. Já existe o de hoje?

Só em execução agendada (prompt "Execução agendada: …"): `search_threads`
com `in:drafts subject:"[Briefing] <dd/mm>"` (data de hoje). Se achar,
encerrar sem coletar nada, relatório "briefing de <dd/mm> já existe". Pedido
manual sempre gera um novo.

Fonte que falhar (conector fora, erro): seguir com as outras e dizer no
briefing qual faltou. Nunca deixar de criar o rascunho por causa de uma fonte.

## 1. Coletar

- **Agenda de hoje:** `list_events` no calendário primário, de 00:00 a
  23:59 (America/Sao_Paulo). Marcar conflitos e o maior bloco livre de 1h+
  entre 09h e 18h (bloco de foco).
- **E-mail:** `label:ia-acao newer_than:3d` e `label:ia-importante
  newer_than:1d is:unread`, `THREAD_VIEW_SUMMARY`. Ação já respondida pelo
  usuário (última mensagem da thread é dele) sai da lista.
- **Sprint:** `project = DOPS AND assignee = currentUser() AND sprint in
  openSprints() AND statusCategory != Done ORDER BY priority DESC, duedate
  ASC` — chave, título, status, prioridade, prazo. Ler `customfield_10010`
  de uma issue para a data de fim da sprint.
- **Novos desde ontem:** `project = DOPS AND assignee = currentUser() AND
  created >= -1d` — espelhos e cards `[GLPI #…]` que o backoffice criou.
- **Espelhos a fechar:** `jira-saude`, seção 2.

Às segundas, também:
- **Agenda da semana:** `list_events` de segunda a sexta, só reuniões
  (sem eventos de dia inteiro de aniversário/feriado de outros).
- **Estagnados:** `jira-saude`, seção 1 (já ordenada por Épico de terceiros
  primeiro).

## 2. Escolher o foco do dia

No máximo 3 itens, nesta ordem de peso:
1. Pedido em `IA/Acao` de VIP ou com prazo hoje/vencido.
2. Card da sprint Muito Alta/Alta ou com prazo até hoje.
3. Card de Épico de terceiros (DOPS-156/207/208) parado ou recém-criado.
4. Preparação de reunião do dia que precise de material.

Cada item: uma linha com o porquê ("prazo hoje", "pedido do X há 2 dias").
Se o dia tiver menos de 2h livres de reunião, dizer isso e reduzir o foco
para 1 item.

Às segundas, acrescentar "Foco da semana": até 3 entregas, olhando prazo,
fim da sprint e estagnados de terceiros.

## 3. Criar o rascunho

Envio é bloqueado pelo admin — sempre `create_draft`, nunca enviar.
`create_draft` com `to` = `gustavo.goncalves@idealtrends.com.br` (só para o
próprio usuário), assunto `[Briefing] <dd/mm> — foco do dia` (segunda:
`[Briefing] <dd/mm> — foco do dia e da semana`), corpo em `htmlBody`:

1. Foco do dia (e da semana, às segundas)
2. Agenda
3. E-mails que pedem ação (com link `viewUrl`)
4. Sprint
5. Novos no DOPS desde ontem
6. Espelhos a fechar / estagnados (segunda)
7. Fontes que falharam (só se houver)

Listas curtas, links para Jira (`https://idealtrends.atlassian.net/browse/
<CHAVE>`) e Gmail. Sem parágrafos de análise.

Relatório final da execução: uma linha com o assunto do rascunho e as fontes
que falharam, se alguma.
