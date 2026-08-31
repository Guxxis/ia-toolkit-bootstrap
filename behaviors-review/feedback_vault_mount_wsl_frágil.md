---
name: feedback-vault-mount-wsl-fragil
description: "O mount WSL do vault Obsidian (/mnt/g/Meu Drive/brain, Google Drive) trava com ENODEV mesmo depois do usuário dizer que reconectou o app Obsidian"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d5add510-ac68-43c1-9238-390d204dc4a5
  modified: 2026-08-12T22:36:45.112Z
---

O mount do vault em `/mnt/g/Meu Drive/brain` (Google Drive montado como G: no Windows, exposto via WSL) pode ficar com handle stale e falhar com `ENODEV: no such device, mkdir '/mnt/g/Meu Drive/brain/...'` em qualquer operação do MCP `obsidian` que precise criar diretório (`write_note` em pasta nova, `search_reindex`). `list_dir`/`recent_notes`/`vault_status` continuam respondendo com dados do índice cacheado mesmo com o mount quebrado, o que engana — parecem funcionar mas `read_note`/`write_note` reais falham.

**Why:** aconteceu em 2026-08-12 durante o planejamento do GrowthMachine — o usuário disse "já conectei o obsidian novamente" (reconectou o app/plugin) mas o erro ENODEV persistiu, porque o problema é o mount do WSL para o drive do Windows, não a conexão do app Obsidian em si. Reconectar o app não remonta o `/mnt/g`.

**How to apply:** antes de confiar em qualquer leitura/escrita do vault nesta sessão, teste com `read_note` ou `write_note` de verdade (não só `list_dir`/`vault_status`) — se der `ENODEV`, o mount está morto e precisa ser restabelecido do lado do Windows/WSL (não é algo que eu resolvo via MCP). Nesse caso, escreva o conteúdo no scratchpad e avise o usuário claramente, sem tentar de novo várias vezes. Relacionado: [[feedback_verificar_escrita_vault_obsidian]] (esse é sobre escrita "silenciosa" que reporta OK mas grava 0 bytes — problema diferente, mesma categoria de "não confiar no retorno do MCP obsidian sem verificar").
