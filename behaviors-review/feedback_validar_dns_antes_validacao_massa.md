---
name: feedback-validar-dns-antes-validacao-massa
description: "Em validação em massa de sites (IDEALPLUS02/HOMOLOG), confirmar o IP/DNS real do domínio antes de diagnosticar um resultado"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 172c06d3-a125-4349-b5b7-f8a645869141
  modified: 2026-08-24T19:08:53.754Z
---

Antes de diagnosticar o resultado de um teste em massa (curl, verificação de bloqueio, etc.) contra um domínio da frota IDEALPLUS02/HOMOLOG, confirmar pra qual IP o domínio resolve publicamente (`getent hosts`/DNS) antes de tirar conclusões sobre o que está ou não configurado no servidor testado.

**Why:** dito explicitamente pelo usuário (2026-08-24) — o grupo está no meio de um processo de migração de sites entre servidores (v1 IDEALPLUS01 → v2 IDEALPLUS02/HOMOLOG), então nem todo domínio que aparece hospedado fisicamente num servidor (`/home/<user>/web/<dominio>`) tem o DNS público apontando pra ele. Descobri isso na prática: `aclimatar.com.br` existe no PLUS02 (usuário `wordpress`) mas o DNS público resolve pra `149.18.102.58` (IDEALPLUS01, legado) — testar via nome de domínio direto deu resultado de OUTRO servidor completamente, gerando um falso alarme de "bloqueio não funciona".

**How to apply:** ao testar um domínio específico via curl/HTTP, sempre rodar `getent hosts <domínio>` primeiro (ou já testar direto via `-H "Host: <domínio>"` contra o IP do servidor, bypassando DNS) antes de reportar um achado como divergência real de config. Em varredura de amostra grande, preferir sempre o bypass por IP+Host em vez de depender do nome DNS resolver certo.
