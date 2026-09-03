---
name: feedback-verificar-escrita-vault-obsidian
description: Escrita no vault via MCP obsidian pode reportar sucesso e deixar o arquivo com 0 bytes — sempre conferir o tamanho depois de editar
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 6139efd0-20af-4acf-a77c-3f3b9a41de01
  modified: 2026-07-28T22:11:34.374Z
---

Depois de **qualquer** escrita no vault (`edit_note`, `append_note`, `write_note`), conferir o tamanho do arquivo antes de seguir. O MCP pode retornar OK com contagem de caracteres plausível e o arquivo terminar **vazio**.

**Why:** em 2026-07-28 fiz 4 `edit_note` no `33_Deploy/Idealtrack/Idealtrack-Prod-Pendencias-Checklist.md`, todos retornando OK (ex: "replaced 245 → 2918 chars"). Minutos depois o arquivo estava com **0 bytes** e o `read_note` devolvia `content: ""` com `mtime` defasado. O `idealtrack-prod-guide.md`, editado no mesmo intervalo, ficou intacto (55 KB) — então não foi falha geral do vault. O vault fica em `G:\Meu Drive\brain` (Google Drive File Stream), o que adiciona uma camada de sync entre o Obsidian e o disco.

**How to apply:**
- Depois de editar, verificar com Python (não com `grep`/`sed`/`Read`, que nesse caminho deram resultados **inconsistentes entre si** — o `grep` enxergava linhas que o `Read` dizia não existir):
  ```python
  import os; print(os.path.getsize("/mnt/g/Meu Drive/brain/<nota>.md"))
  ```
- Em edição longa ou de nota importante, salvar a versão pretendida no scratchpad ANTES de escrever no vault, para poder restaurar.
- Se achar um arquivo zerado: **não sobrescrever de imediato**. O Drive pode ter a versão boa na nuvem (arquivo desidratado/dessincronizado localmente) e escrever por cima destrói a única cópia íntegra. Primeiro pedir ao usuário para checar o histórico de versões do Drive e o *File recovery* do Obsidian (fica em IndexedDB, não em disco — não há `.obsidian/file-recovery/` para inspecionar).
- 🔴 **O arquivo pode se recuperar sozinho entre a verificação e a escrita** — foi o que aconteceu: 20 min depois de eu ver 0 bytes, o Drive re-hidratou o arquivo para 26010 bytes, e eu **sobrescrevi a versão recuperada** porque o meu script *imprimia* o tamanho antes de escrever em vez de **abortar** se fosse diferente de zero. Imprimir não protege. A escrita tem que ser condicional no mesmo passo atômico:
  ```python
  n = os.path.getsize(DST)
  if n != 0:
      raise SystemExit(f"ABORTADO: destino tem {n} bytes — recuperou sozinho, não sobrescrever")
  ```
- Depois de restaurar por reconstrução, **não afirmar que ela equivale ao original** sem conseguir fechar a conta de bytes. Neste caso a diferença (430 bytes) não fechou com a explicação óbvia (~306), então o certo é dizer que há divergência não explicada e apontar o histórico de versões do Drive para comparação.

Relacionado: [[project_idealtrack_prod]]
