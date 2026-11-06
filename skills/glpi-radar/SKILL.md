---
name: glpi-radar
description: Varre o GLPI (idealtrends.us1.glpi-network.cloud) atrás dos chamados em aberto atribuídos ao usuário como técnico e cria automaticamente, sem aprovação, um card espelho no Jira (projeto DOPS) para cada chamado que ainda não tem um. Pensado para rodar agendado, igual ao Modo 1 da jira-radar. Use quando o usuário disser "roda o radar do GLPI", "puxa meus chamados do GLPI", "o que tem no GLPI sem card no Jira", ou periodicamente a pedido dele. Não use para formalizar um chamado GLPI específico colado na conversa com brainstorm e refinamento (isso é jira-ticket-creator) nem para varrer o Jira (isso é jira-radar).
---

# GLPI Radar

## Relação com outras skills (não duplicar)

Formato de descrição (Pedido/Origem/Contexto adicional), proibição de
`**negrito**` na descrição e Épicos vêm de `jira-ticket-creator`; detalhes
do MCP Atlassian (conector, `cloudId`, prioridade por `id`, `parent` como
objeto) estão em "Descobertas técnicas" de `jira-radar`. Releia os dois antes
de criar qualquer issue — se divergirem desta skill, eles são a fonte de
verdade.

**Exceção deliberada:** sem gate de aprovação — o usuário decidiu que todo
chamado GLPI aberto atribuído a ele vira card no DOPS automaticamente.

## Credenciais

`~/.config/glpi-radar.env` (fora do repositório, criado pelo usuário):
```
GLPI_URL=https://idealtrends.us1.glpi-network.cloud
GLPI_APP_TOKEN=<App-Token do cliente de API, Configurar → Geral → API>
GLPI_USER_TOKEN=<chave de acesso remoto, Preferências → Chaves de acesso remoto>
```
Nunca ler, exibir ou gravar os tokens — só rodar o script. Se o arquivo
faltar, avisar o usuário e parar. A API v1 exige App-Token nesta instância e
só roteia em `/api/<endpoint>` — `apirest.php/<endpoint>` e `api.php/v1/...`
devolvem `ERROR_SESSION_TOKEN_MISSING` até no `initSession`. A v2
(`api.php/v2`) está desabilitada.

## 1. Buscar chamados

```
bash ~/.claude/skills/glpi-radar/glpi-open-tickets.sh
```
Retorna array JSON `{id, titulo, status, abertura, link, descricao}` com os
chamados não solucionados/fechados em que o usuário é técnico atribuído
(chamados atribuídos só ao grupo não entram). Erro HTTP do script → reportar
e parar, sem criar nada.

## 2. Filtrar os que já têm card

Para cada chamado:
```
project = DOPS AND (summary ~ "\"GLPI #<id>\"" OR summary ~ "\"GLPI-<id>\"")
```
Cards criados à mão usam `[GLPI-<id>]`; os do radar, `[GLPI #<id>]`. Achou issue (qualquer status) → pular. Card concluído no DOPS com chamado
ainda aberto no GLPI não é recriado — só citar no relatório.

## 3. Criar o card (automático, sem aprovação)

- Projeto DOPS, tipo `Tarefa`, `parent` = DOPS-156.
- Título: `[GLPI #<id>] <titulo>`.
- Responsável: o próprio usuário (accountId do `atlassianUserInfo`).
- Prioridade: `id` 3 (Média), sempre.
- Story points: não preencher. Sprint: nenhuma (backlog). Sem subtasks.
- Descrição:
  ```
  Pedido
  <titulo> — <resumo da descricao em 2-4 linhas; "sem descrição no chamado" se vazia>

  Origem
  - Canal: GLPI #<id> (<link>)
  - Aberto em: <abertura>
  ```

## 4. Relatório

Lista curta: chave nova → `GLPI #<id>` + título; chamados pulados por já
terem card concluído; falhas; ou "nenhum chamado novo". Nada além disso.

## Modo dry-run

Se o usuário pedir "dry-run"/"só lista", fazer só os passos 1 e 2 e mostrar
em tabela o que seria criado, sem escrever no Jira.
