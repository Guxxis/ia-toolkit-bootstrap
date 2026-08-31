---
name: feedback-secrets-so-comando-nao-executar
description: "Para comandos que geram/manipulam segredos (APP_KEY, senhas, chaves), só passar o comando — não executar direto no servidor, mesmo em sessão onde o usuário já autorizou várias outras ações via SSH"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d5add510-ac68-43c1-9238-390d204dc4a5
  modified: 2026-08-14T17:45:57.323Z
---

Durante a depuração do GrowthMachine em homolog (2026-08-14), eu vinha executando várias correções direto no servidor via SSH (systemd, templates nginx, `.env` DB_HOST/REDIS_HOST, migrations) sem o usuário pedir confirmação a cada uma. Quando pedi pra gerar o `APP_KEY` do Laravel (`php artisan key:generate`), o usuário rejeitou a execução e disse "só me dê o comando, não execute".

**Why:** parece ser uma linha diferente da que ele traça pra outras mudanças de infra — comandos que geram ou manipulam segredo/chave/senha ele prefere rodar com as próprias mãos, mesmo quando já vinha deixando eu executar livremente ações de config/debug no mesmo servidor, na mesma sessão.

**How to apply:** quando o próximo passo for gerar, rotacionar ou expor um segredo (`key:generate`, criar senha, mostrar `.env` com credencial, etc.), dar o comando pronto pra copiar e parar — não executar via Bash/SSH — mesmo que o restante da sessão já tenha tido execução direta autorizada implicitamente. Relacionado: [[feedback_prefer_ansible_over_manual_fixes]] (outra distinção de "o que eu posso tocar direto vs o que fica pro usuário").
