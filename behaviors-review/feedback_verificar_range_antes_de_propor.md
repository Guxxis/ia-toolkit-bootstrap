---
name: feedback-verificar-range-antes-de-propor
description: Nunca propor range de IP/VPC sem checar o estado real na Digital Ocean primeiro
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 84df6e43-a5e5-4c98-abe1-12336a4b9c7e
  modified: 2026-08-09T17:12:28.170Z
---

Ao planejar CIDR/VPC pro grupo, não proponha um número "livre" baseado só no que está documentado
em repos locais ou no vault — **cheque o estado real primeiro** (`doctl vpcs list` com o token do
team certo, ou peça print do dashboard DO). Two vezes propus ranges errados na mesma conversa
([[reference_vpc_cidr_ranges]]): (1) reservei `10.30.0.0/16`/`10.40.0.0/16` pra Doutores da
Web/Busca Cliente sem saber que já eram, na prática, os teams de Soluções Industriais e Unitrends;
(2) coloquei a plataforma nova do Vision em `10.20.x` (junto do IdealTrack) achando que era o mesmo
team DO, quando na real cada empresa/produto tem team/token próprio na DO — só depois de rodar
`doctl vpcs list` e o usuário mandar prints do dashboard é que a topologia real apareceu.

**Por quê:** documentação local (repos, vault, memória) fica desatualizada ou nunca existiu pra
decisões que alguém tomou direto no console da nuvem. Terraform só mostra o que FOI aplicado por
aquele código — não mostra o que outro time criou manualmente ou por outro repo.

**Como aplicar:** antes de fechar qualquer plano de rede/infra que dependa de "o que já existe",
rodar o comando de leitura real (`doctl`, `terraform show`, API do provedor) ou pedir confirmação
visual (print do dashboard) — nunca assumir que a ausência de menção em repo/vault significa que o
recurso não existe.
