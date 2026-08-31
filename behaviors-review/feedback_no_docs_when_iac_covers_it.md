---
name: feedback-no-docs-when-iac-covers-it
description: "Usuário não quer documentação separada (diagnóstico, nota no vault, etc) quando a mudança já está versionada como IaC commitada"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a03c4a93-6427-4d7f-9c76-257df3213fc2
---

Depois de implementar e commitar uma mudança de infra como código (ex: migração TimescaleDB do Zabbix em `devops.jumphost`, ver [[project_jumphost_zabbix_perf]]), o usuário disse explicitamente "como temos tudo no repositório como IaC, não precisa documentar".

**Why:** pra esse usuário, o código versionado (Ansible/Terraform) já É a documentação — um diagnóstico separado (Jira via `diagnostic-creator`, nota no vault Obsidian) seria redundante quando a mudança foi planejada, implementada e commitada dentro da própria sessão, com o plano de implementação já registrado.

**How to apply:** não oferecer proativamente `diagnostic-creator` ou salvar nota no vault Obsidian para mudanças de infra que já resultam em commit de IaC — a menos que o usuário peça explicitamente, ou que a mudança envolva um *incidente* real (algo quebrou em produção) em vez de uma melhoria planejada. Isso é diferente de memória própria do Claude (que continua valendo) — é sobre não empurrar documentação *para o usuário/time* quando o código já cobre esse papel.
