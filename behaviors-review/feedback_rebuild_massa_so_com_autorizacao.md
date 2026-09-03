---
name: feedback-rebuild-massa-so-com-autorizacao
description: "Rebuild em massa (v-rebuild-web-domains, todos os domínios de um usuário Hestia) só com autorização explícita a cada vez"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 172c06d3-a125-4349-b5b7-f8a645869141
  modified: 2026-08-25T19:30:58.678Z
---

Nunca rodar `v-rebuild-web-domains <user> yes` (rebuild em massa, todos os domínios de um usuário) sem pedir e receber autorização explícita do usuário antes, mesmo que pareça óbvio que a mudança é segura ou já tenha sido validada em teoria.

**Why:** dito explicitamente em 2026-08-25, depois de uma sequência de rebuilds em massa mal coordenados (dois processos concorrentes no mesmo servidor por engano, condição de corrida real) durante a correção de uma regressão. Rebuild em massa afeta centenas de sites de uma vez e é caro/demorado de reverter.

**How to apply:** usar sempre `v-rebuild-web-domain <user> <domain>` (singular, sem "yes"/restart) pra testar em sites específicos primeiro — de preferência os da lista oficial de teste ([[reference_idealplus_dominios_teste]]). Rodar `nginx -t` pra confirmar sintaxe, e só pedir autorização pro **restart** do nginx (não é automático mesmo com `-t` validado). Só depois de validar funcionalmente nos sites de teste, perguntar se expande pra mais alguns, e só perguntar por autorização de rebuild em massa quando o usuário indicar que quer fechar/generalizar a mudança.
