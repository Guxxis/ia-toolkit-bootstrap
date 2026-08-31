---
name: feedback-investigar-reportar-antes-executar
description: "Em execução de correções de infra/hardening em servidores, investigar e reportar o estado atual antes de aplicar qualquer mudança"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: da1bff88-e2df-420e-90ca-d1f9799b2aa6
  modified: 2026-08-24T14:44:53.252Z
---

Ao aplicar correções em servidores (hardening, configs, etc.), sempre investigar e ler o estado atual primeiro, reportar a situação encontrada ao usuário, e só executar a mudança depois disso — não seguir direto de "encontrei o problema" para "corrigi".

**Why:** dito explicitamente durante a execução do [[project_dops330_360_365_escopo]] (2026-08-24), depois de eu já ter removido os dump_migracao.sql (DOPS-335) direto ao encontrá-los. O usuário quer visibilidade do diagnóstico antes da ação, mesmo quando a correção parece óbvia/de baixo risco.

**How to apply:** para cada subtarefa/item de hardening, primeiro rodar os comandos de leitura/diagnóstico, apresentar o achado (o que está configurado hoje vs. o que deveria estar), e aguardar confirmação explícita antes de aplicar a mudança no servidor — mesmo em itens que pareçam de baixo risco. Vale para toda a sequência do DOPS-330 (331/332/333/334/360/361/362/364) e para trabalhos futuros similares nesses servidores.
