---
name: email-rules-suggest
description: Analisa os últimos 30 dias de e-mail já classificados pela email-triage, encontra padrões (remetente, domínio, lista, assunto) e erros de classificação, e deixa como rascunho no Gmail, endereçado ao próprio usuário, filtros do Gmail prontos para criar à mão e ajustes propostos para a lista de remetentes. Não cria filtro nem edita arquivo. Roda às sextas no cron do agente-consultor e sob demanda quando o usuário disser "sugere regras de e-mail", "que filtros eu crio", "o que dá pra automatizar no meu e-mail".
---

# Email Rules Suggest

O conector do Gmail não cria filtros — esta skill só propõe. A
`email-triage` define as labels; `references/remetentes.md` dela é a lista
que esta skill propõe ajustar.

## 1. Coletar

Para cada label (`ia-acao`, `ia-importante`, `ia-info`,
`ia-spam-suspeito`): `search_threads` com `label:<label> newer_than:30d`,
`THREAD_VIEW_METADATA_ONLY`, paginando até 300 threads por label.

Sinais de erro de classificação (só para as threads que entrarem nos
candidatos, para não abrir tudo):
- `IA/Info` ou `IA/Spam-suspeito` em que o usuário respondeu (há mensagem
  dele, `in:sent`, na thread) → deveria ter subido.
- `IA/Acao` que continua `UNREAD` há mais de 7 dias → talvez seja ruído.
- Label `IA/*` removida pelo usuário não é detectável — não tente inferir.

## 2. Encontrar padrões

Agrupar por endereço do remetente, depois por `@dominio` e `list-id`. Um
grupo vira candidato quando tem 5 ou mais threads e 90% ou mais caíram na
mesma label. Ignore remetentes já presentes em `remetentes.md`.

## 3. Propor

Para cada candidato, uma linha com: padrão, quantidade/label, e a proposta
— uma de:
- **Filtro Gmail**: query pronta (ex.: `from:(noreply@exemplo.com)`) +
  ação (pular a caixa de entrada e aplicar label X; nunca "excluir" nem
  "marcar como spam" — isso o usuário decide se quiser).
- **remetentes.md**: linha pronta para colar na seção certa (VIP, ruído
  Info, ruído Spam).

Erros de classificação vão numa seção própria, com a correção sugerida.
Máximo de 15 propostas, as de maior volume primeiro.

## 4. Criar o rascunho

`create_draft` (nunca enviar) com `to` = `gustavo.goncalves@idealtrends.com.br` (só para o
próprio usuário), assunto `[Consultor] Sugestões de regras de e-mail —
<dd/mm>`, corpo em `htmlBody` com as propostas em lista. Sem candidatos: criar mesmo assim, uma
linha "nenhum padrão novo esta semana".

Relatório final da execução: número de propostas e se o rascunho foi criado.
