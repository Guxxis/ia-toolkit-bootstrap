---
name: feedback-pm2-legado-usar-supervisor
description: pm2 é legado no grupo Ideal Trends; usar supervisor (+ cron p/ scheduler) para processos long-running de Laravel
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 075765e4-b480-4336-b029-aeca5ab4ca56
  modified: 2026-07-21T22:34:05.724Z
---

O usuário confirmou (2026-07-21) que **pm2 é legado** no grupo — foi usado pontualmente nas primeiras pipelines e não é mais o padrão. O `deploy.sh` canônico em `pipeline-library/templates/scripts/deploy.sh` ainda faz `pm2 restart ecosystem.config.cjs` mas está **desatualizado**.

**Padrão atual para processos long-running de Laravel (Horizon/Reverb):** `supervisor`.
- Horizon: `php artisan horizon:terminate` no deploy (sem sudo; supervisor respawna).
- Reverb: `sudo supervisorctl restart <grupo>:<reverb>` (1 linha de sudoers).
- Scheduler: **cron do usuário** (`schedule:run` a cada minuto apontando p/ `current`), não supervisor.
- `.conf` do supervisor aponta p/ o symlink `current` (nunca release absoluta — [[project_hestia_capistrano_template]]); versionar no repo em `deploy/supervisor/` e idealmente no Ansible da frota.

**Why:** evitar recomendar pm2 baseado no template legado. **How to apply:** ao planejar deploy de app PHP com filas/websocket no grupo, assumir supervisor+cron. Contexto: split do auditoriaideal.com.br (DOPS-47), ver vault 40_Projetos/Auditoria.
