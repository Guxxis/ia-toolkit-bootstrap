---
name: feedback-sem-comentarios-em-configs-servidor
description: "Não adicionar comentários explicativos (referência a ticket, motivo da mudança) em arquivos de config/templates aplicados nos servidores"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 172c06d3-a125-4349-b5b7-f8a645869141
  modified: 2026-08-25T20:44:37.973Z
---

Ao editar arquivos de configuração/templates em servidores (nginx, fail2ban, etc.), não incluir comentários explicando a mudança — **principalmente referência a número de ticket do Jira** (ex: "Bloqueio de superfícies administrativas — DOPS-361"), mas vale pra explicação de motivo/contexto em geral.

**Why:** dito explicitamente durante a execução do DOPS-330/361 (2026-08-24) — o usuário considera esse tipo de referência interna da conversa/decisão (principalmente o vínculo a ticket), não algo que deva viver no arquivo do servidor. Nota: templates anteriores (ex: `wp-secure.stpl`, `jail.local`) já têm comentários desse estilo com referência a DOPS-XXX de rodadas anteriores (Ansible/DOPS-360) — não é preciso removê-los retroativamente, a regra vale pra edições novas.

**How to apply:** ao editar nginx templates, jail.local, filtros do fail2ban ou qualquer config nos servidores IDEALPLUS02/HOMOLOG (ou similares), escrever só a diretiva funcional, sem comentário de contexto/motivo. Explicar o "porquê" na resposta do chat, não no arquivo. Ver [[feedback_comentarios_curtos_codigo]] (mesma linha, já aplicada a código de aplicação).

**Extensão 2026-08-25**: a mesma regra vale pro repositório Ansible (`infra.idealplus.idealtrends.io`), não só configs ao vivo nos servidores — usuário pediu explicitamente pra evitar comentários longos e referências a DOPS/Jira nos arquivos `.j2`/tasks/etc, mesmo quando o repo já tem esse estilo em commits antigos (não é pra imitar o estilo antigo). Comentário aceitável: uma linha curta explicando o "o quê"/"por quê" técnico do bloco (ex: "chave sempre vazia = nginx trata como sem limitação"), sem data, sem número de ticket, sem parágrafo de histórico.
