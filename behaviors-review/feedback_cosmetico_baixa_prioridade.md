---
name: feedback_cosmetico_baixa_prioridade
description: "Usuário desprioriza melhorias cosméticas/nice-to-have; propor uma vez, registrar como manutenção futura e seguir"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a8ac2a5d-5e3f-4fbb-8365-ec70e922d905
  modified: 2026-07-28T14:06:23.052Z
---

Quando eu proponho um ajuste que é melhoria e não correção de problema real, o usuário
adia: *"não é prioridade apenas cosméticos"* e *"pode ser uma manutenção para o futuro"*.
Exemplos em 2026-07-28: desligar cores ANSI do log do NestJS, ligar access log do Traefik.

**Why:** ele está tocando várias frentes de infra em paralelo (ver [[project_idealtrack_prod]])
e quer o tempo em coisa que destrava trabalho ou corrige perda real — não em polimento.
Perda silenciosa de log ele mandou corrigir na hora; log feio no Discover ele adiou.

**How to apply:** propor **uma vez**, com o custo/benefício claro, e aceitar o "depois" sem
insistir. Ao adiar, **registrar no vault** com o achado técnico já apurado (inclusive o que
não funcionaria) para ninguém re-investigar do zero. Não reabrir o assunto em turnos
seguintes. O critério que ele usa: corrige perda/erro real → agora; melhora experiência
ou estética → depois.
