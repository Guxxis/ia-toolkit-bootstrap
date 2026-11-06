---
name: jira-saude
description: Relatório somente leitura da saúde do DOPS — tickets estagnados (sem atualização há 14+ dias, priorizando Épicos de terceiros) e espelhos cuja issue original já foi concluída (candidatos a fechar). Nunca escreve no Jira. Usada pelo daily-brief do agente-consultor e sob demanda quando o usuário disser "tickets parados/estagnados", "os espelhos já podem fechar", "saúde do DOPS". Não use para montar sprint (isso é jira-sprint) nem para criar espelhos (isso é jira-radar).
---

# Jira Saúde (somente leitura)

Conector, `cloudId` e `view: "full"`: ver "Descobertas técnicas" de
`jira-radar`. Esta skill só relata — nunca comenta, edita, transiciona nem
fecha nada. Se o usuário pedir uma ação a partir do relatório, isso é com o
`agente-backoffice` (`jira-ticket-creator`/`jira-sprint`, com aprovação).

## 1. Tickets estagnados

JQL:
```
project = DOPS AND statusCategory != Done AND updated <= -14d ORDER BY updated ASC
```
14 dias é o default; se o usuário pedir outro limite ("mostra parado há mais
de 30 dias"), use o dele. Reporte em lista simples: chave, título,
responsável, data da última atualização, dias parado.

**Prioridade dos Épicos (não tratar toda estagnação igual):** os Épicos
DOPS-1, 46, 47, 48, 49 e 50 são projetos internos de melhoria/padronização da
área de DevOps — importantes, mas sem SLA externo. DOPS-156, 207 e 208 são
solicitações de terceiros (outro time ou empresa da holding) com prazo e SLA
de resposta. Separar ou rebaixar a urgência de issues estagnadas dentro de
DOPS-1/46-50 frente às estagnadas dentro de DOPS-156/207/208 — estas
últimas são o sinal que realmente importa.

## 2. Espelhos a fechar

Busque issues do DOPS ainda não concluídas (`statusCategory != Done`) que
tenham `issuelinks` do tipo `Relates` apontando para fora do DOPS. Para cada
uma, o status da issue linkada já vem embutido no payload de `issuelinks` —
não precisa de chamada extra. Se a original estiver com `statusCategory`
"Concluído"/Done, sinalize: "a original X foi concluída — considere
transicionar/fechar o espelho DOPS-Y".

Espelhos de GLPI (`[GLPI #<id>]` no título) não têm link Jira — não entram
nesta checagem.
