# Snapshot da configuração atual do Claude Code (WSL root, 2026-07-03)

Este documento existe porque o ambiente atual roda o Claude Code CLI como **usuário `root`** dentro do WSL, o que não é o ideal (sem isolamento de usuário, `HOME=/root`, dependência de pontes SSH frágeis). Antes de resetar o WSL e reconstruir o ambiente do zero (provavelmente com um usuário não-root), este arquivo captura **tudo que está configurado hoje**, o que já foi versionado neste repositório e o que ainda precisa de ação manual depois de um reset.

## 1. Onde cada coisa mora hoje

| O quê | Caminho real (root) | Versionado aqui? |
|---|---|---|
| CLAUDE.md global | `~/.claude/CLAUDE.md` (`@RTK.md`) | ✅ `claude-md/CLAUDE.md` |
| Instruções do RTK | `~/.claude/RTK.md` | ✅ `claude-md/RTK.md` |
| CLAUDE.md do workspace principal | `/root/CLAUDE.md` (Obsidian + Jira) | ✅ `claude-md/workspace-CLAUDE.md` |
| Settings globais | `~/.claude/settings.json` | ✅ `settings/claude-settings.json` |
| Statusline | `~/.claude/statusline-command.sh` | ✅ `settings/statusline-command.sh` |
| Skills customizadas | `~/.claude/commands/{diagnostic-creator,infra-planner}/SKILL.md` | ✅ `skills/diagnostic-creator/`, `skills/infra-planner/` |
| Config global do Claude Code (`.claude.json`) | symlink para `/mnt/c/Users/gustavo.goncalves/projetos/workspace/config/claude/.claude.json` (fora do WSL, no NTFS) | ⚠️ não versionado — ver seção 4 |
| Permissões acumuladas | `~/.claude/settings.local.json` | ❌ não versionado de propósito — ver seção 5 |
| Memória automática | `~/.claude/projects/-root/memory/` | ❌ não versionado — ver seção 6 |
| RTK (binário + filtros) | `~/.local/bin/rtk` (v0.43.0), `~/.config/rtk/filters.toml` | ✅ instalado via `setup.sh`, filtros só com exemplos comentados (nada custom a preservar) |
| MCP Obsidian | registrado no projeto `/root` dentro do `.claude.json` | ✅ template em `mcp/config.template.json` |
| MCP Jira | registrado no projeto `/root` dentro do `.claude.json` (com token em texto puro!) | ⚠️ template em `mcp/config.template.json`, token NUNCA commitado |
| Marketplace de plugins | `claude-plugins-official` (oficial, auto-registrado) | ❌ não precisa versionar — o Claude Code registra sozinho |

## 2. RTK — Rust Token Killer

Proxy de CLI que filtra/compacta saída de comandos (git, grep, find, ls, etc.) antes de chegar no contexto do modelo. Hoje é acionado via hook `PreToolUse` em `settings.json` (`rtk hook claude` em todo `Bash`), e o `CLAUDE.md` global importa `RTK.md` para ensinar o agente a usar `rtk <comando>` diretamente em vez do comando nativo.

- Repo: https://github.com/rtk-ai/rtk
- Instalação: `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh` (instala em `~/.local/bin/rtk`) — já incluído no `setup.sh`.
- Config de filtros custom: `~/.config/rtk/filters.toml` (hoje só tem o template comentado, nada para migrar).

## 3. Skills customizadas (não confundir com skills de terceiros)

Skills reais, autorais, com lógica de negócio do Grupo Ideal Trends — por isso versionadas em `skills/`:

- **`diagnostic-creator`** — gera diagnósticos técnicos pós-incidente e salva no vault Obsidian (`39_Diagnostics/`).
- **`infra-planner`** — planeja infraestrutura de projetos novos, lê os repos, consulta o vault e produz Guia + Checklist.

Hoje ambas vivem em `~/.claude/commands/<nome>/SKILL.md` (não em `~/.claude/skills/`) — as duas localizações funcionam no Claude Code atual. O `setup.sh` deste repo symlinka para `~/.claude/skills/`, que é o local recomendado.

**Não versionadas** (não são autorais, são reinstaláveis):
- `skill-creator`, `opsx`, `openspec-*` — vêm de marketplaces/pacotes oficiais (`openspec` CLI, marketplace `claude-plugins-official`). Depois do reset, reinstale via o mecanismo de plugins do Claude Code ou `npx openspec init`, não precisa copiar arquivo nenhum.
- As pastas `diagnostic-creator-workspace/` e `infra-planner-workspace/` dentro de `~/.claude/commands/` são artefatos de avaliação (evals) gerados pelo `skill-creator` ao criar as skills acima — lixo de processo, não configuração.

## 4. `.claude.json` — o arquivo mais sensível

O `.claude.json` do usuário fica fisicamente fora do WSL, em `/mnt/c/Users/gustavo.goncalves/projetos/workspace/config/claude/.claude.json`, com `~/.claude.json` sendo um **symlink** para lá. Essa é uma boa prática (sobrevive a reset do WSL), mas o arquivo:

1. Guarda o **token do Jira em texto puro** dentro de `projects["/root"].mcpServers.jira.args`.
2. Guarda dados de sessão/telemetria do Claude Code (`oauthAccount`, `machineID`, caches) que não fazem sentido versionar.

**Por isso este arquivo nunca deve ir para o git.** Ao reconfigurar do zero:

- Se for manter o mesmo usuário do Windows: o symlink para o caminho no NTFS pode ser recriado (o arquivo em si sobrevive ao reset do WSL, já que mora fora dele). Confirme que o `oauthAccount` ainda é válido; se não, rode `claude login`.
- Os MCPs (`obsidian`, `jira`) precisam ser re-registrados via `claude mcp add` (o `setup.sh` já faz isso interativamente, pedindo a API key/token na hora — nunca fica hardcoded em lugar nenhum do repo).
- **Considere rotacionar o token do Jira** na próxima oportunidade, já que ele ficou em texto puro num arquivo de configuração por um bom tempo.

## 5. `settings.local.json` — permissões acumuladas

Esse arquivo cresce organicamente conforme você aprova `Bash(...)`, MCPs e skills durante o uso normal do Claude Code. Hoje tem ~110 entradas, a maioria comandos pontuais de investigação (curls de diagnóstico, greps específicos) que não fazem sentido "restaurar" — são ruído de sessões passadas, não configuração intencional.

Por isso **não foi versionado neste repo de propósito**. O que vale a pena lembrar de reconfigurar manualmente (ou deixar reconstruir sozinho no uso normal):
- `enabledMcpjsonServers: ["obsidian"]`
- Permissões amplas úteis no dia a dia: `Bash(rtk *)`, `Bash(git config *)`, `WebSearch`, `Skill(update-config)`, `mcp__obsidian__*` de leitura.

## 6. Memória automática (`~/.claude/projects/-root/memory/`)

O sistema de memória (aprendizados sobre você, feedback, projetos, referências) é local e **não é coberto por este repositório**. Ele será perdido num reset de WSL. Isso é esperado — não é "configuração de ambiente", é histórico de conversas. Se quiser preservar o conteúdo mais importante (ex: os projetos DEVOPS-43, Jumphost, Idealtrack), o caminho natural é migrar esse conhecimento para o vault Obsidian (fonte de verdade duradoura), não para este repo.

## 7. Checklist pós-reset (ordem sugerida)

1. `wsl-ansible-bootstrap` → roles `system`, `ssh-relay`, `docker`, `db` (infra base do WSL).
2. Role `ia-config` → instala Claude Code CLI global.
3. `git clone` deste repo (`ia-toolkit-bootstrap`) + `bash setup.sh`:
   - instala o `rtk`
   - instala `CLAUDE.md`/`RTK.md`/statusline em `~/.claude/`
   - symlinka as skills (`diagnostic-creator`, `infra-planner`) para `~/.claude/skills/`
   - aplica `settings.json` (se ainda estiver no padrão mínimo)
   - pede interativamente a API key do Obsidian e o token do Jira para registrar os MCPs
4. `pipx install mcp-atlassian` (dependência do MCP do Jira, se o `setup.sh` ainda não tiver essa etapa automatizada).
5. Copiar `claude-md/workspace-CLAUDE.md` para o diretório de trabalho principal (hoje é `/root`; num setup não-root, deve ser a raiz do workspace, ex: `~/Workspace/CLAUDE.md` ou o diretório onde você abre o Claude Code no dia a dia).
6. `claude login` se necessário.
7. Confirmar `.claude.json` (ver seção 4) — symlink para fora do WSL ou recriar do zero.
8. Reautorizar via uso normal as permissões que fizerem sentido (seção 5) — não precisa restaurar tudo de uma vez.

## 8. Recomendação: sair do usuário `root`

A causa raiz de vários dos pontos frágeis acima (ponte SSH não ativa neste shell, `.claude.json` amarrado ao projeto `/root`, `CLAUDE.md` de workspace vivendo em `/root` em vez de um diretório de projeto de verdade) é rodar o Claude Code como `root`. Ao reconstruir o WSL, vale considerar criar um usuário não-root dedicado (o `wsl-ansible-bootstrap` já tem estrutura de roles para isso) e usar `$HOME/Workspace` como raiz — evita side effects de permissão e deixa o `CLAUDE.md` do workspace num lugar mais natural.
