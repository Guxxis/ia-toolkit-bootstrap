---
name: diagnostic-creator
description: Gera documentos de diagnóstico técnico pós-incidente (postmortem) estruturados em .md e os sobe na pasta post-mortem do Google Drive da equipe DevOps, devolvendo o link — usada pela skill incident-postmortem para o comentário final do card de incidente. Use esta skill sempre que o usuário acabou de resolver um problema técnico e quer documentá-lo, menciona "criar diagnóstico", "documentar incidente", "registrar problema", "fazer post-mortem", "documentar o que aconteceu com X", ou similar. Use também quando o usuário descreve um problema que resolveu sem pedir explicitamente um diagnóstico — nesses casos a documentação quase sempre é desejada, então ofereça. Não ofereça proativamente quando a mudança já foi commitada como Infraestrutura como Código (Ansible/Terraform) dentro da própria sessão — nesse caso o código versionado já é a documentação; ofereça só se for um incidente real (algo quebrou em produção) ou se o usuário pedir explicitamente.
---

# Diagnostic Creator

Skill para gerar documentos de diagnóstico técnico pós-incidente (postmortem) em `.md` e salvá-los na pasta `post-mortem` do Google Drive da equipe DevOps.

O objetivo é capturar conhecimento institucional: o que deu errado, por quê, e como foi corrigido — para que quando o mesmo problema (ou similar) ocorrer novamente, a equipe consiga resolver mais rápido e sem partir do zero.

## Passo 1: Extraia o máximo do contexto da conversa

Antes de fazer qualquer pergunta, releia tudo o que já foi dito na conversa. Se o usuário já descreveu o problema e a solução, extraia:

- O que foi o problema
- Onde ocorreu (servidor, sistema, ambiente)
- Qual foi o sintoma observado
- O que causou o problema (causa raiz)
- O que foi feito para resolver
- Quais servidores/serviços foram afetados

Só pergunte sobre informações que genuinamente estão faltando. Não faça perguntas redundantes com o que já está na conversa.

## Passo 2: Preencha apenas as lacunas

Para qualquer informação ausente, faça as perguntas em uma única mensagem — nunca uma de cada vez. O mínimo necessário para um diagnóstico útil:

- **Problema:** O que aconteceu? (uma ou duas frases)
- **Sintoma:** O que foi observável? (mensagem de erro, métrica anormal, reclamação de usuário)
- **Causa raiz:** Por que aconteceu?
- **Solução:** O que foi feito para corrigir? (inclua comandos, configs ou mudanças específicas se possível)
- **Sistemas afetados:** Quais servidores, serviços ou ambientes foram impactados?

Opcionais — pergunte só se relevante ou se o usuário quiser mais detalhe:
- Timeline: quando foi detectado? quanto tempo durou?
- Como foi detectado? (alerta, relato de usuário, verificação manual)
- Há incidentes anteriores relacionados?

## Passo 3: Gere o diagnóstico

Leia o template em `references/template.md` e preencha com as informações coletadas. Quando chamada pela skill `incident-postmortem`, inclua também a timeline e a lista de subtasks com o resultado de cada uma que ela passar.

**Convenção de nomenclatura:**
`postmortem-[TASK-ID]-[HOST]-[PROBLEMA].md`

- `TASK-ID`: chave do card de origem no Jira. Sem card (uso fora de incidente), use `SEM-TASK`.
- `HOST`: nome do servidor como aparece no Zabbix.
- `PROBLEMA`: 2-4 palavras em kebab-case, sem acento.

Exemplos:
- `postmortem-DOPS-512-DSW-MKT01-loop-workers-php-fpm.md`
- `postmortem-DOPS-497-MPIPLUS-FERRAMENTAS-disco-logs-mariadb.md`
- `postmortem-SEM-TASK-IDEALPLUS01-backup-timeout.md`

**Regras inegociáveis de conteúdo:**

- **Sempre em português** — título, seções, texto e ações preventivas
- **Causa raiz profunda** — "o serviço crashou" não é causa raiz. Por que crashou? Era uma configuração ausente? Uma regra de monitoramento faltando? Um padrão que não deveria ter sido mantido? Vá fundo.
- **Comandos e configs verbatim** — quando a solução envolveu comandos específicos ou blocos de configuração, inclua o texto exato em blocos de código. Isso é o que torna o diagnóstico realmente útil na próxima vez.
- **Ações preventivas acionáveis e com responsável marcado** — "melhorar monitoramento" não é uma ação. "Configurar alerta no Zabbix para CPU > 80% no IDEALPLUS01" é. Cada item deve ser específico o suficiente para ser atribuído a alguém, e **sempre** começar com a tag de quem é o responsável, entre `**duplo asterisco**`:
  - `**Infra/DevOps:**` — infraestrutura, servidores, monitoramento, deploy, configuração de ambiente
  - `**Dev/TechLead:**` — código, arquitetura, revisão técnica, correção de bug
  - `**PO/PMO:**` — priorização, aprovação de negócio, decisão de produto, comunicação com stakeholders

  Combine tags com `+` quando a ação depender de mais de um papel (ex: `**Dev/TechLead + PO/PMO:**`). Nunca deixe uma ação sem tag de responsável — é o que torna o item atribuível de verdade.
- **Links para incidentes relacionados** — se o incidente tem conexão com um anterior (mesma causa, mesmo servidor, mesmo padrão), cite a chave do card no Jira e, se houver, o link do postmortem anterior no Drive.
- **Nunca inclua IPs internos, senhas ou credenciais** — use apenas nomes de servidor, domínios e usuários de sistema.

## Passo 4: Suba o arquivo no Drive

Destino: pasta `post-mortem` do drive compartilhado "Devops Tecnologia GIT" (conta devops@, compartilhada como colaborador), folderId `1XbprcVVQLRCsbHtWkMgWmzE0XzNh4FRT`.

```
mcp__claude_ai_Google_Drive__create_file(
  title: "postmortem-[TASK-ID]-[HOST]-[PROBLEMA].md",
  parentId: "1XbprcVVQLRCsbHtWkMgWmzE0XzNh4FRT",
  textContent: <conteúdo gerado>,
  contentMimeType: "text/markdown",
  disableConversionToGoogleType: true
)
```

`disableConversionToGoogleType: true` é obrigatório — o arquivo tem que ficar como `.md`, não virar Google Doc. Antes de subir, procure um arquivo com o mesmo título na pasta (`search_files` com `parentId = '1XbprcVVQLRCsbHtWkMgWmzE0XzNh4FRT' and title = '...'`); se existir, pergunte ao usuário se sobe uma nova versão (sufixo `-v2`) em vez de duplicar em silêncio.

Depois do upload, confira com `get_file_metadata` que o arquivo existe e não está vazio, e capture o `viewUrl`.

### Fallback — Drive indisponível

Salve em `$CLAUDE_JOB_DIR/tmp/` ou `/tmp/` com o mesmo nome, informe o caminho exato e peça para o usuário subir manualmente na pasta `post-mortem`. Não tente de novo várias vezes.

## Passo 5: Devolva o link

Informe o link do arquivo no Drive e liste as ações preventivas em aberto — são os próximos passos concretos para evitar recorrência.

- Chamada pela `incident-postmortem`: devolva o link para ela, que posta o comentário final no card de origem via `incident-comment`. Não comente no Jira a partir desta skill.
- Chamada fora de incidente (sem card): só o upload e o link, nada no Jira.
