---
name: incident-plan-refine
description: Refina o plano sugerido na triagem de um incidente usando o contexto da empresa trazido pelo usuário na sessão (complexidade, ações iniciais, pessoas envolvidas, sequência), e transforma cada etapa do plano final aprovado em subtask do card de origem no Jira. Use depois de incident-triage, ou quando o usuário disser "vamos refinar o plano do DOPS-XXX", "monta as subtasks do incidente", "o plano mudou, refaz". Não cria ticket novo — as subtasks ficam sempre sob o card do Zabbix que originou o incidente.
---

# Incident Plan Refine

Segunda parte da fase inicial do agente `analista-de-incidentes`.

## Passo 1: Partir da triagem

Leia o card de origem com comentários. O ponto de partida é o último
comentário `[Incidente] Fase: Triagem` (ou o último `Refinamento`, se for
um re-refinamento). Sem triagem no card, sugira rodar `incident-triage`
primeiro.

## Passo 2: Coletar o contexto da empresa

O contexto vem da conversa desta sessão — não há arquivo de referência.
Pergunte em uma única mensagem, em texto corrido, só o que ainda não foi
dito:

- Criticidade do sistema/cliente afetado e se há SLA.
- Quem precisa ser envolvido ou avisado (dev responsável, PO, cliente).
- Janela permitida para mudança e restrições (horário, freeze, aprovação).
- Algo já tentado fora do que está no card.

Não invente pessoas nem responsáveis; se o usuário não souber, registre
como pendência.

## Passo 3: Propor o plano final

Tabela com uma linha por etapa, na ordem de execução:

| # | Etapa | Tipo (diagnóstico/mudança/comunicação) | Quem executa | Critério de validação |

Mais: complexidade estimada (baixa/média/alta, com o motivo), ações
iniciais imediatas e riscos. Cada etapa é uma tarefa de nível único — sem
subitens. Mudança em servidor tem sempre o usuário como executor.

Refine com o usuário até ele aprovar o plano.

## Passo 4: Criar as subtasks

Regra: cada etapa do plano final aprovado vira uma subtask do card de
origem — nem mais, nem menos. Só crie depois do "pode criar" explícito.

`mcp__claude_ai_Atlassian__createJiraIssue` com:

- `parent`: chave do card de origem (string, ex. `"DOPS-512"`).
- tipo de issue: Subtarefa.
- summary: `[<#>] <Etapa>`.
- descrição curta: tipo, quem executa, critério de validação.
- prioridade por id (`{"id": "3"}`) herdada da prioridade do card de
  origem — nunca por nome.

A subtask herda a sprint do pai; não tente definir sprint. Em re-refinamento,
não apague subtasks existentes — crie só as etapas novas e liste as que
ficaram obsoletas para o usuário fechar manualmente.

## Passo 5: Comentário de fase

Via `incident-comment`, fase `Refinamento`, com o plano final, as chaves
das subtasks criadas e as pendências. Esse comentário é disparado pela
skill, então mostre o rascunho e só poste depois do "ok" do usuário.
