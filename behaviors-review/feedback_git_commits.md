---
name: feedback_git_commits
description: "Usuário revisa e faz commits/pushes manualmente — não executar git commit, push ou git config sem instrução explícita"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 496630b8-bd04-46c3-a237-7cf2b021d54e
---

Não executar `git commit`, `git push`, `git config` ou qualquer operação git destrutiva/modificadora sem instrução explícita.

**Why:** O usuário prefere validar todas as mudanças antes de commitar ou subir qualquer alteração. O controle do git é dele.

**How to apply:** Em tarefas de DevOps/CI (como configuração de Jenkinsfile), apenas propor e editar arquivos localmente. Nunca commitar nem fazer push automaticamente.
