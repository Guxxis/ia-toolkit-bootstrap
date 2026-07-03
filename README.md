# ia-toolkit-bootstrap

Infraestrutura como código para o agente de IA. Versiona comportamentos (CLAUDE.md, RTK, skills, configs MCP, settings) para padronizar o uso do Claude Code em qualquer WSL — sem depender de reconstruir tudo na mão depois de um reset.

> Veja [`docs/CURRENT-SETUP.md`](docs/CURRENT-SETUP.md) para o mapeamento completo entre "o que está configurado hoje" e "o que este repo versiona", incluindo o que fica de fora de propósito (segredos, permissões acumuladas, memória) e o checklist de reconfiguração pós-reset.

## Instalação em novo WSL

```bash
git clone <repo-url> ~/Workspace/ia-toolkit-bootstrap
bash ~/Workspace/ia-toolkit-bootstrap/setup.sh
source ~/.bashrc   # ou ~/.zshrc
```

O `setup.sh` instala o `rtk`, aplica `CLAUDE.md`/`RTK.md`/statusline em `~/.claude/`, symlinka as skills para `~/.claude/skills/` e pede interativamente as credenciais dos MCPs (Obsidian e Jira) — nenhum segredo fica hardcoded no repo.

## Estrutura

```
ia-toolkit-bootstrap/
├── setup.sh                     # bootstrap — instala rtk, aplica configs, registra MCPs
├── aliases.sh                   # aliases de terminal (sourced pelo .bashrc/.zshrc)
├── claude-md/
│   ├── CLAUDE.md                 # → ~/.claude/CLAUDE.md (importa RTK.md)
│   ├── RTK.md                    # → ~/.claude/RTK.md — instruções de uso do RTK
│   └── workspace-CLAUDE.md       # CLAUDE.md do diretório de trabalho principal (Obsidian + Jira)
├── prompts/                      # personas para colar manualmente no início de uma sessão
│   ├── devops_senior.md
│   └── sdd_expert.md
├── skills/                       # skills autorais (SKILL.md), symlinked para ~/.claude/skills/
│   ├── diagnostic-creator/
│   └── infra-planner/
├── mcp/
│   └── config.template.json     # template dos MCPs (obsidian + jira), com placeholders
├── settings/
│   ├── claude-settings.json     # template para ~/.claude/settings.json (model, hooks, statusline)
│   └── statusline-command.sh    # → ~/.claude/statusline-command.sh
├── docs/
│   └── CURRENT-SETUP.md         # snapshot da config real + checklist de reconfiguração
└── .logs/
    └── sessions.log             # (se o hook Stop de log estiver ativo no seu settings.json)
```

## Aliases

| Alias       | Ação                                          |
|-------------|------------------------------------------------|
| `toolkit`   | navega para `~/Workspace/ia-toolkit-bootstrap` |
| `tk-devops` | exibe persona DevOps Senior                    |
| `tk-sdd`    | exibe persona SDD Expert                       |
| `tk-list`   | lista prompts disponíveis                      |
| `tk-update` | `git pull` no toolkit                          |
| `tk-log`    | monitora log de sessões em tempo real          |
| `tk-setup`  | re-executa o script de configuração            |

## RTK (Rust Token Killer)

Proxy de CLI que compacta a saída de comandos antes de chegar no contexto do modelo (git, grep, find, ls, etc.), acionado via hook `PreToolUse` em `settings.json`. Ver `claude-md/RTK.md` para o guia de uso e `docs/CURRENT-SETUP.md` §2 para instalação/detalhes.

## Adicionar nova skill

1. Crie a pasta em `skills/nome-da-skill/SKILL.md` seguindo o formato de skill do Claude Code (com `references/` se precisar de arquivos auxiliares)
2. Rode `tk-setup` para criar o symlink automaticamente em `~/.claude/skills/`
3. Faça commit e push para manter versionado

Skills de terceiros/oficiais (`skill-creator`, `openspec-*`, plugins de marketplace) **não** entram aqui — são reinstaláveis, não autorais. Ver `docs/CURRENT-SETUP.md` §3.

## Ativar uma persona

Copie o conteúdo de `prompts/` e use como contexto inicial da sessão, ou referencie diretamente no `CLAUDE.md` do seu projeto.
