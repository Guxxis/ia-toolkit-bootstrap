---
name: feedback-ssh-bridge-claude-code-root
description: "O shell do Claude Code (root, WSL) não tem autenticação SSH funcional com o GitHub — não tentar git fetch/pull/push por SSH sem avisar o usuário antes"
metadata: 
  node_type: memory
  type: project
  originSessionId: 660dfa52-3e26-4170-812a-3c02228ba797
---

O ambiente sandbox deste Claude Code (usuário `root` no WSL) não tem acesso SSH funcional ao GitHub: nenhuma das chaves em `~/.ssh/` (`id_wsl_guxxis`, `id_rsa`, `chave_web`, `id_devops_backup`, `id_ansible`) é aceita pelo GitHub, `~/.ssh/agent.sock` (ponte para o SSH agent do Windows, usada pelo `ia-toolkit`) não existe/não está ativo nesta sessão, e `gh` CLI não está instalado.

**Why:** a ponte SSH real mora no terminal WSL "de verdade" do usuário (fora do Claude Code), via `socat`/`npiperelay.exe` encaminhando para o SSH agent do Windows. O shell que o Claude Code usa aqui é um processo separado sem essa ponte ativa.

**How to apply:** antes de rodar `git fetch`/`pull`/`push` num repo que exige SSH, não assumir que vai funcionar — ou avisar o usuário do bloqueio e perguntar como proceder (ele pode preferir rodar o `git pull`/`push` manualmente no terminal real dele), ou tentar contornar (ex: `ssh-keyscan` para popular `known_hosts` resolve o "host key verification failed", mas não resolve a falta de chave aceita). Ver [[project_ia_toolkit_bootstrap]] para o caso concreto onde isso aconteceu.
