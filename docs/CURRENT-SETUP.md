# Snapshot da configuração atual do Claude Code (WSL root, 2026-08-31)

Atualização do snapshot de 2026-07-03 (commit `44bb877`), feita antes de uma formatação do PC. Continua rodando como **`root`** no WSL (a recomendação da seção 8 de sair do root não foi executada ainda). Este arquivo captura tudo que está configurado hoje, o que já foi versionado neste repo e o que precisa de ação manual pós-reset.

## 0. A cadeia completa de reconstrução

Este repo é só a **Fase 2** (IA). A ordem real é:

1. **`wsl-ansible-bootstrap`** (`Guxxis/wsl-ansible-bootstrap`, repo próprio, com remote no GitHub) — cria o WSL do zero: `bootstrap.sh` instala Ansible e roda `playbook.yaml` com as roles `system` (systemd, Zsh, Node 24 via NodeSource, clientes de banco, mount automático do Google Drive `G:` em `/mnt/g` via fstab), `ssh-relay` (ponte socat+npiperelay para o SSH Agent do Windows), `docker`, `db` e **`ia-config`**.
2. A role **`ia-config`** é o elo: instala o Claude CLI globalmente (`npm install -g @anthropic-ai/claude-code`) e depois clona/atualiza `git@github.com:Guxxis/ia-toolkit-bootstrap.git` em `~/Workspace/ia-toolkit-bootstrap` e roda o `setup.sh` dele.
3. **`ia-toolkit-bootstrap`** (este repo) — o que está documentado no restante deste arquivo.

`wsl-ansible-bootstrap` é IaC de verdade (Ansible), então não tem um "CURRENT-SETUP.md" próprio — o código já é a documentação. Único ponto de atenção: `playbook.yaml` tem `git_email: "gustavo.silva97@hotmail.com"` hardcoded nas vars — confirme se é o e-mail que você quer usar antes de rodar num WSL novo.

## 1. Onde cada coisa mora hoje

| O quê | Caminho real (root) | Versionado aqui? |
|---|---|---|
| CLAUDE.md global | `~/.claude/CLAUDE.md` (`@RTK.md`) | ✅ `claude-md/CLAUDE.md` |
| Instruções do RTK | `~/.claude/RTK.md` | ✅ `claude-md/RTK.md` |
| CLAUDE.md do workspace principal | `/root/CLAUDE.md` (Obsidian + Jira) | ✅ `claude-md/workspace-CLAUDE.md` |
| Regra global Context7 | `~/.claude/rules/context7.md` | ✅ `rules/context7.md` (novo desde jul/26) |
| Settings globais | `~/.claude/settings.json` | ✅ `settings/claude-settings.json` |
| Statusline | `~/.claude/statusline-command.sh` | ✅ `settings/statusline-command.sh` |
| Skills autorais | `~/.claude/commands/{diagnostic-creator,infra-planner,jira-ticket-creator}/SKILL.md` | ✅ `skills/` |
| Config global do Claude Code (`.claude.json`) | symlink para `/mnt/c/Users/gustavo.goncalves/projetos/workspace/config/claude/.claude.json` (fora do WSL, no NTFS) | ⚠️ não versionado — ver seção 4 |
| Permissões acumuladas | `~/.claude/settings.local.json` | ❌ de propósito — ver seção 5 |
| Memória automática | `~/.claude/projects/-root/memory/` (86 arquivos hoje) | ❌ não versionado — ver seção 6 |
| RTK (binário + filtros) | `~/.local/bin/rtk` (v0.43.0, sem mudança desde jul) | ✅ instalado via `setup.sh` |
| MCP Obsidian | projeto `/root` no `.claude.json`, pacote **`@blacksmithers/obsidian-forge-mcp`** apontando pro path do vault | ✅ template em `mcp/config.template.json` (pacote trocado desde jul — era `obsidian-mcp-server` + API key REST) |
| MCP Jira | projeto `/root` no `.claude.json` (token em texto puro!) | ⚠️ template em `mcp/config.template.json`, token NUNCA commitado |
| MCP Context7 | **global** no `.claude.json` (`.mcpServers`, não dentro de `projects`), HTTP + `CONTEXT7_API_KEY` em texto puro | ⚠️ novo desde jul; template em `mcp/config.template.json`, key NUNCA commitada |
| Plugin ponytail | marketplace `dietrichgebert/ponytail` (`~/.claude/plugins/`), habilitado em `settings.json.enabledPlugins` | ❌ reinstalável — ver seção 3 |
| Marketplace oficial | `claude-plugins-official` (auto-registrado) | ❌ não precisa versionar |

## 2. RTK — Rust Token Killer

Sem mudanças desde jul/26 (ainda v0.43.0). Ver README/`claude-md/RTK.md`.

## 3. Skills e plugins

Skills autorais (versionadas em `skills/`, com lógica de negócio do Grupo Ideal Trends):

- **`diagnostic-creator`** — diagnósticos pós-incidente no vault Obsidian.
- **`infra-planner`** — planejamento de infra de projetos novos.
- **`jira-ticket-creator`** *(nova desde ago/26)* — formaliza pedido/incidente como issue no Jira (projeto DOPS), com aprovação explícita antes de criar.

Hoje vivem em `~/.claude/commands/<nome>/SKILL.md`; o `setup.sh` symlinka para `~/.claude/skills/` (local recomendado atual).

**Não versionadas** (reinstaláveis):
- `skill-creator`, `opsx`, `openspec-*`, `context7-mcp` — de marketplaces/pacotes oficiais. Reinstale via mecanismo de plugins do Claude Code, `npx openspec init`, ou deixe o registro do MCP Context7 recriar a skill sozinho.
- **`ponytail`** *(novo desde ago/26)* — plugin de marketplace (`github:dietrichgebert/ponytail`, v4.8.4). Reinstale com `claude plugin marketplace add dietrichgebert/ponytail && claude plugin install ponytail@ponytail` (o `setup.sh` já tenta fazer isso). Fica registrado em `settings.json` (`enabledPlugins`, `extraKnownMarketplaces`) — por isso o `settings.json` inteiro é versionado, não só um template mínimo.
- `diagnostic-creator-workspace/`, `infra-planner-workspace/` dentro de `~/.claude/commands/` — lixo de eval do `skill-creator`, não configuração.

## 4. `.claude.json` — o arquivo mais sensível

Continua symlink para `/mnt/c/Users/gustavo.goncalves/projetos/workspace/config/claude/.claude.json` (fora do WSL, sobrevive a reset). Segredos em texto puro hoje:

1. **Token do Jira** — `projects["/root"].mcpServers.jira.args` (sem mudança desde jul, ainda não rotacionado).
2. **API key do Context7** — `mcpServers.context7.headers.CONTEXT7_API_KEY` (novo desde jul, também em texto puro, também nunca deve ir para o git).
3. Dados de sessão/telemetria (`oauthAccount`, `machineID`, caches) — não versionar.

Ao reconfigurar do zero: recriar o symlink (o arquivo sobrevive fora do WSL), confirmar `oauthAccount` válido (`claude login` se não), re-registrar os 3 MCPs via `claude mcp add` (obsidian e jira em scope de projeto, context7 em `--scope user`) — o `setup.sh` já pede as 3 chaves interativamente. **Considere rotacionar Jira token e Context7 key** na próxima janela de manutenção.

## 5. `settings.local.json` — permissões acumuladas

Continua não versionado de propósito (hoje ~259 linhas, ruído de sessões passadas). Reautorize por uso normal; vale lembrar `enabledMcpjsonServers: ["obsidian"]` e permissões amplas de uso diário (`Bash(rtk *)`, `WebSearch`, etc.).

## 6. Memória automática (`~/.claude/projects/-root/memory/`)

Cresceu de ~15 arquivos (jul/26) para **86 arquivos** (ago/26) — projetos, feedback e referências acumulados de meses de uso operacional (incidentes IDEALPLUS, IdealTrack prod, Jumphost, etc.). Continua não coberta por este repo e será perdida num reset do WSL — esperado, é histórico de conversas, não config de ambiente. Se algo ali for conhecimento que precisa sobreviver de verdade, o caminho é migrar para o vault Obsidian antes do reset, não para este repo.

## 7. Checklist pós-reset (ordem sugerida)

1. `wsl-ansible-bootstrap` → `bash bootstrap.sh` (roda todas as roles: `system`, `ssh-relay`, `docker`, `db`).
2. A role `ia-config` (dentro do mesmo playbook) já instala o Claude CLI e clona + roda o `setup.sh` deste repo automaticamente — não precisa repetir manualmente, mas se for só a parte de IA: `git clone` + `bash setup.sh`, que hoje:
   - instala o `rtk`
   - instala `CLAUDE.md`/`RTK.md`/`rules/*.md`/statusline em `~/.claude/`
   - symlinka as 3 skills autorais para `~/.claude/skills/`
   - aplica `settings.json` (se ainda estiver no padrão mínimo — hoje ele carrega o plugin ponytail e um bloco `autoMode` grande, então provavelmente vai cair no caminho de merge manual)
   - pede interativamente as credenciais dos 3 MCPs (Obsidian, Jira, Context7)
   - registra o marketplace + instala o plugin `ponytail`
3. `pipx install mcp-atlassian` antes do MCP do Jira, se ainda não automatizado.
4. Copiar `claude-md/workspace-CLAUDE.md` para o diretório de trabalho principal.
5. `claude login` se necessário.
6. Confirmar `.claude.json` (seção 4).
7. Reautorizar por uso normal as permissões que fizerem sentido (seção 5).
8. Se quiser preservar conhecimento da memória automática (seção 6), migrar para o vault Obsidian **antes** de reformatar.

## 8. Recomendação: sair do usuário `root`

Ainda válida e ainda não executada. Causa raiz de vários pontos frágeis (ponte SSH, `.claude.json` amarrado ao projeto `/root`, `CLAUDE.md` de workspace em `/root`). O `wsl-ansible-bootstrap` já assume um usuário não-root em boa parte do design (`become: false`, `git_email`/`git_name` de usuário), mas hoje ele está sendo executado diretamente como `root` — vale decidir isso antes do próximo reset, não depois.
