---
name: diagnostic-creator
description: Gera documentos de diagnóstico técnico pós-incidente estruturados e os salva no vault Obsidian (39_Diagnostics/). Use esta skill sempre que o usuário acabou de resolver um problema técnico e quer documentá-lo, menciona "criar diagnóstico", "documentar incidente", "registrar problema", "fazer post-mortem", "documentar o que aconteceu com X", ou similar. Use também quando o usuário descreve um problema que resolveu sem pedir explicitamente um diagnóstico — nesses casos a documentação quase sempre é desejada, então ofereça.
---

# Diagnostic Creator

Skill para gerar documentos de diagnóstico técnico pós-incidente e salvá-los no vault Obsidian.

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

## Passo 3: Verifique o vault para seguir o formato estabelecido

Antes de escrever, confira o padrão dos diagnósticos já existentes no vault:

1. `mcp:obsidian → list_dir("39_Diagnostics")` — lista os arquivos existentes
2. `mcp:obsidian → read_note(<diagnóstico mais recente>)` — lê um para referência de estilo

Isso garante que o novo diagnóstico siga o mesmo padrão de estrutura, uso de emojis, tabelas e convenção de nomenclatura dos outros — e pareça que pertence ao vault, não que veio de outro sistema.

Se o MCP Obsidian não estiver disponível, pule este passo e use o template padrão em `references/template.md`.

## Passo 4: Gere o diagnóstico

Leia o template em `references/template.md` e preencha com as informações coletadas. Adapte o template ao estilo do vault se houver divergência.

**Convenção de nomenclatura:**
`Diagnostico-[Sistema]-[ProblemaBreve].md`

Exemplos:
- `Diagnostico-WordPress-XMLRPC-CPU-Spike.md`
- `Diagnostico-Nginx-502-PHP-FPM.md`
- `Diagnostico-IDEALPLUS01-Backup-Timeout.md`

**Regras inegociáveis de conteúdo:**

- **Sempre em português** — título, seções, texto e ações preventivas
- **Causa raiz profunda** — "o serviço crashou" não é causa raiz. Por que crashou? Era uma configuração ausente? Uma regra de monitoramento faltando? Um padrão que não deveria ter sido mantido? Vá fundo.
- **Comandos e configs verbatim** — quando a solução envolveu comandos específicos ou blocos de configuração, inclua o texto exato em blocos de código. Isso é o que torna o diagnóstico realmente útil na próxima vez.
- **Ações preventivas acionáveis e com responsável marcado** — "melhorar monitoramento" não é uma ação. "Configurar alerta no Zabbix para CPU > 80% no IDEALPLUS01" é. Cada item deve ser específico o suficiente para ser atribuído a alguém, e **sempre** começar com a tag de quem é o responsável, entre `**duplo asterisco**`:
  - `**Infra/DevOps:**` — infraestrutura, servidores, monitoramento, deploy, configuração de ambiente
  - `**Dev/TechLead:**` — código, arquitetura, revisão técnica, correção de bug
  - `**PO/PMO:**` — priorização, aprovação de negócio, decisão de produto, comunicação com stakeholders

  Combine tags com `+` quando a ação depender de mais de um papel (ex: `**Dev/TechLead + PO/PMO:**`). Nunca deixe uma ação sem tag de responsável — é o que torna o item atribuível de verdade.
- **Links para diagnósticos relacionados** — se o incidente tem conexão com um anterior (mesma causa, mesmo servidor, mesmo padrão), adicione um `[[wiki-link]]` para o diagnóstico relacionado.

## Passo 5: Gere o artefato HTML

**Sempre gere um artefato HTML** usando o design system definido em `references/html-report.html`. Este é o formato de compartilhamento externo — deve ser gerado em toda execução da skill, independente de o vault estar disponível ou não.

**Regras para o HTML:**

- Escreva o arquivo no scratchpad da sessão (ex: `/tmp/...`)
- Publique com a ferramenta `Artifact` (favicon: `🔍`)
- **Capture a URL retornada pela ferramenta `Artifact`** — ela será incluída na nota do vault no Passo 6
- O link do artefato pode ser compartilhado com pessoas fora da organização via PDF (`Ctrl+P → Salvar como PDF`) ou como arquivo HTML
- **Nunca inclua IPs, senhas ou credenciais no HTML** — use apenas nomes de servidor, domínios e nomes de usuário de sistema quando necessário
- Adapte as seções ao contexto: diagnósticos de incidente resolvido diferem de diagnósticos de bug em aberto

**Seções obrigatórias do HTML (ver estrutura completa em `references/html-report.html`):**

1. **doc-header** — título do diagnóstico e metadados (servidor, sistema, stack, data)
2. **summary-strip** — 3 cards de resumo: causas confirmadas / hipóteses descartadas / status de resolução
3. **findings** — um card `.finding` por causa raiz: identificador `RC-XX`, severidade, título, descrição, evidência em `code-evidence`, impacto. Aplique `.pulse` no finding de maior severidade
4. **hipóteses descartadas** — card `.finding.f-ok` para itens investigados e descartados
5. **recomendações** — `.rec-block` com lista numerada de ações. Cada `.rec-item` deve trazer um badge de responsável (`badge-infra` = Infra/DevOps, `badge-dev` = Dev/TechLead, `badge-po` = PO/PMO), usando exatamente a mesma tag atribuída ao item correspondente na seção "Ações Preventivas" do Markdown — use dois badges no mesmo item quando a ação depender de mais de um papel. Nunca gere um `.rec-item` sem badge de responsável.
6. **scope-note** — nota de escopo quando parte da investigação ficou fora do alcance
7. **doc-footer** — sistema · data

**Classes de severidade:** `f-crit` (vermelho), `f-warn` (laranja), `f-ok` (verde)

**Highlight de código nos blocos `code-evidence`:**
- `.hl` — linha problemática (laranja)
- `.cm` — comentário (cinza escuro)
- `.ok` — linha correta ou esperada (verde)
- `.kw` — keyword (roxo)
- `.str` — string (verde-limão)
- `.anno` — anotação crítica (vermelho bold)

## Passo 6: Salve o diagnóstico no vault

A nota do vault deve incluir a URL do artefato HTML gerado no Passo 5. Adicione-a na seção `## Referências` do documento, em formato de link Markdown:

```markdown
## Referências

- Artefato HTML: [Visualizar relatório](https://claude.ai/code/artifact/XXXX)
- Servidor: ...
- Diagnósticos relacionados: [[nome-do-diagnostico]]
```

### Preferencial — MCP Obsidian disponível:

```
mcp:obsidian → write_note(
  path: "39_Diagnostics/Diagnostico-[Sistema]-[ProblemaBreve].md",
  content: <conteúdo gerado, com URL do artefato na seção Referências>
)
```

### Fallback — MCP Obsidian indisponível:

Salve como arquivo `.md`, nesta ordem de preferência:
1. `~/Desktop/Diagnostico-[Sistema]-[ProblemaBreve].md`
2. `/tmp/Diagnostico-[Sistema]-[ProblemaBreve].md`

Informe o usuário exatamente onde o arquivo foi salvo e instrua a movê-lo manualmente para `39_Diagnostics/` no vault.

## Passo 7: Confirme e destaque as ações abertas

Após salvar, informe o link do artefato HTML e o caminho do arquivo no vault, e liste as ações preventivas em aberto — elas são os próximos passos concretos que o usuário deve tomar para evitar a recorrência do problema.
