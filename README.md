# ia-toolkit

Infraestrutura como código para o agente de IA. Versiona comportamentos (prompts/personas, skills, configs MCP) para padronizar o uso do Claude Code em qualquer WSL.

## Instalação em novo WSL

```bash
git clone <repo-url> ~/Workspace/ia-toolkit
bash ~/Workspace/ia-toolkit/setup.sh
source ~/.bashrc
```

## Estrutura

```
ia-toolkit/
├── setup.sh              # bootstrap — configura aliases, symlinks e settings
├── aliases.sh            # aliases de terminal (sourced pelo .bashrc)
├── prompts/              # personas para o agente
│   ├── devops_senior.md
│   └── sdd_expert.md
├── skills/               # skills do Claude Code (symlinked para ~/.agents/skills/)
├── mcp/
│   └── config.template.json   # template de mcp_config.json
├── settings/
│   └── claude-settings.json   # template para ~/.claude/settings.json
└── .logs/
    └── sessions.log      # registro automático de sessões (via hook Stop)
```

## Aliases

| Alias       | Ação                                      |
|-------------|-------------------------------------------|
| `toolkit`   | navega para `~/Workspace/ia-toolkit`      |
| `tk-devops` | exibe persona DevOps Senior               |
| `tk-sdd`    | exibe persona SDD Expert                  |
| `tk-list`   | lista prompts disponíveis                 |
| `tk-update` | `git pull` no toolkit                     |
| `tk-log`    | monitora log de sessões em tempo real     |
| `tk-setup`  | re-executa o script de configuração       |

## Adicionar nova skill

1. Crie o arquivo em `skills/nome-da-skill.md` seguindo o formato de skill do Claude Code
2. Rode `tk-setup` para criar o symlink automaticamente
3. Faça commit e push para manter versionado

## Protocolo de uso (Harness Engineering)

Cada sessão do Claude Code registra automaticamente timestamp e diretório em `.logs/sessions.log` via hook `Stop` no `settings.json`. Use `tk-log` para monitorar.

Para ativar uma persona: copie o conteúdo de `prompts/` e use como contexto inicial da sessão, ou referencie diretamente no seu `CLAUDE.md` de projeto.
