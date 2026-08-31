---
name: feedback-comentarios-curtos-codigo
description: Comentários no código devem ser curtos — nada de parágrafo explicando o raciocínio inteiro na linha
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 84df6e43-a5e5-4c98-abe1-12336a4b9c7e
  modified: 2026-08-09T23:03:02.098Z
---

Quando um comentário é necessário (WHY não-óbvio), manter em **uma linha curta**, não um parágrafo
com o raciocínio completo (causa, mecanismo, por que a correção funciona). O usuário corrigiu
depois de eu ter escrito ~7 linhas de comentário explicando por que tirar `cache_valid_time` do apt
resolvia um 404 de mirror do Ubuntu — motivo dado: "isso suja o repositório".

**Por quê:** comentário longo no código synchronizes uma prosa de PR/explicação pra dentro do
arquivo, que fica ali para sempre incomodando quem só quer ler a lógica. A explicação detalhada
pertence à conversa/mensagem de commit, não à linha de código.

**Como aplicar:** ao justificar uma mudança não-óbvia em código (Ansible, Terraform, qualquer
linguagem), dar o contexto completo na resposta ao usuário (chat), e deixar só uma frase mínima
como comentário inline — o suficiente pra alguém não reverter a mudança sem saber por quê, nada
além disso.
