# Estilo de comentário em código e config

- Quando um comentário é necessário (WHY não-óbvio), manter em uma linha curta — não um parágrafo explicando causa, mecanismo e por que a correção funciona. A explicação completa vai na resposta ao usuário (chat/commit message), não no arquivo.
- Ao editar configs/templates de servidor (nginx, fail2ban, etc.) ou o repositório Ansible (`.j2`, tasks, defaults), não incluir comentários de contexto/motivo — e principalmente não referenciar número de ticket (Jira/DOPS). Explicar o "porquê" no chat. Um comentário técnico curto sobre o "o quê" de um bloco é aceitável (sem data, sem ticket, sem histórico); vale para edições novas, não é preciso remover comentários antigos já existentes no estilo antigo.
