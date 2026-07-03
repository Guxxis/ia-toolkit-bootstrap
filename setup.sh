#!/bin/bash
# ia-toolkit-bootstrap setup — bootstrap para novo WSL
# Uso: bash ~/Workspace/ia-toolkit-bootstrap/setup.sh

set -e

TOOLKIT="$HOME/Workspace/ia-toolkit-bootstrap"
AGENTS_SKILLS="$HOME/.agents/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"
CLAUDE_DIR="$HOME/.claude"
BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"

echo "🔧 Configurando ia-toolkit-bootstrap..."

# 1. Instalar rtk (proxy CLI de otimização de tokens) se ausente
if ! command -v rtk &> /dev/null; then
  echo ""
  echo "📦 Instalando rtk (github.com/rtk-ai/rtk)..."
  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
else
  echo "  ⏭  rtk já instalado ($(rtk --version 2>/dev/null))"
fi

# 2. CLAUDE.md global + RTK.md — instrução do RTK carregada em toda sessão
mkdir -p "$CLAUDE_DIR"
cp "$TOOLKIT/claude-md/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
cp "$TOOLKIT/claude-md/RTK.md" "$CLAUDE_DIR/RTK.md"
echo "  ✅ ~/.claude/CLAUDE.md e RTK.md instalados"

# 3. Statusline
cp "$TOOLKIT/settings/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
chmod +x "$CLAUDE_DIR/statusline-command.sh"
echo "  ✅ statusline instalada"

# 4. Skills (formato SKILL.md em diretório) → symlink para ~/.claude/skills/
mkdir -p "$CLAUDE_SKILLS"
for skill_dir in "$TOOLKIT/skills/"*/; do
  [ -d "$skill_dir" ] || continue
  name=$(basename "$skill_dir")
  if [ ! -e "$CLAUDE_SKILLS/$name" ]; then
    ln -sf "$skill_dir" "$CLAUDE_SKILLS/$name"
    echo "  ✅ skill symlinked: $name"
  else
    echo "  ⏭  skill já existe: $name"
  fi
done

# 5. Prompts/personas antigos (formato .md solto) — mantido por compatibilidade
mkdir -p "$AGENTS_SKILLS"
for skill in "$TOOLKIT/skills/"*.md; do
  [ -f "$skill" ] || continue
  name=$(basename "$skill")
  if [ ! -L "$AGENTS_SKILLS/$name" ]; then
    ln -sf "$skill" "$AGENTS_SKILLS/$name"
    echo "  ✅ skill (legado) symlinked: $name"
  fi
done

# 6. Source aliases no .bashrc e .zshrc (idempotente)
for rc_file in "$BASHRC" "$ZSHRC"; do
  touch "$rc_file"
  # Remove entrada antiga com caminho sem -bootstrap se existir
  sed -i '/ia-toolkit\/aliases\.sh/d' "$rc_file"
  if ! grep -q "ia-toolkit-bootstrap/aliases.sh" "$rc_file"; then
    echo "" >> "$rc_file"
    echo "# ia-toolkit" >> "$rc_file"
    echo "source $TOOLKIT/aliases.sh" >> "$rc_file"
    echo "  ✅ aliases adicionados ao $(basename "$rc_file")"
  else
    echo "  ⏭  aliases já estão no $(basename "$rc_file")"
  fi
done

# 7. Aplicar settings do Claude Code (só se estiver no padrão mínimo ou inexistente)
CLAUDE_SETTINGS="$CLAUDE_DIR/settings.json"
if [ ! -f "$CLAUDE_SETTINGS" ]; then
  echo '{"theme": "dark"}' > "$CLAUDE_SETTINGS"
fi

current=$(cat "$CLAUDE_SETTINGS")
if [ "$current" = '{"theme": "dark"}' ] || [ "$current" = '{"theme":"dark"}' ] || [ -z "$current" ]; then
  cp "$TOOLKIT/settings/claude-settings.json" "$CLAUDE_SETTINGS"
  echo "  ✅ ~/.claude/settings.json atualizado"
else
  echo "  ⏭  ~/.claude/settings.json já customizado — merge manual necessário"
  echo "     Template disponível em: $TOOLKIT/settings/claude-settings.json"
fi

# 8. Registrar MCP do Obsidian no Claude Code
if command -v claude &> /dev/null; then
  if [ -z "$OBSIDIAN_API_KEY" ]; then
    echo ""
    echo "🔑 Para configurar o MCP do Obsidian, informe a API key (plugin Local REST API):"
    read -rp "   OBSIDIAN_API_KEY (deixe em branco para pular): " OBSIDIAN_API_KEY
  fi

  if [ -n "$OBSIDIAN_API_KEY" ]; then
    claude mcp add obsidian \
      -e OBSIDIAN_API_KEY="$OBSIDIAN_API_KEY" \
      -e OBSIDIAN_BASE_URL="https://127.0.0.1:27124" \
      -e NODE_TLS_REJECT_UNAUTHORIZED="0" \
      -- npx -y obsidian-mcp-server 2>/dev/null \
      && echo "  ✅ MCP obsidian registrado no Claude Code" \
      || echo "  ⏭  MCP obsidian já estava registrado"
  else
    echo "  ⏭  OBSIDIAN_API_KEY não informada — MCP não registrado"
    echo "     Rode depois: claude mcp add obsidian -e OBSIDIAN_API_KEY=<chave> -e OBSIDIAN_BASE_URL=https://127.0.0.1:27124 -e NODE_TLS_REJECT_UNAUTHORIZED=0 -- npx -y obsidian-mcp-server"
  fi

  # 9. Registrar MCP do Jira (mcp-atlassian) — requer `pipx install mcp-atlassian` antes
  if command -v mcp-atlassian &> /dev/null || [ -x "$HOME/.local/bin/mcp-atlassian" ]; then
    if [ -z "$JIRA_API_TOKEN" ]; then
      echo ""
      echo "🔑 Para configurar o MCP do Jira, informe os dados (deixe em branco para pular):"
      read -rp "   JIRA_URL (ex: https://idealtrends.atlassian.net): " JIRA_URL
      read -rp "   JIRA_USERNAME (seu e-mail): " JIRA_USERNAME
      read -rsp "   JIRA_API_TOKEN: " JIRA_API_TOKEN
      echo ""
    fi

    if [ -n "$JIRA_API_TOKEN" ] && [ -n "$JIRA_URL" ] && [ -n "$JIRA_USERNAME" ]; then
      claude mcp add jira \
        -- "$HOME/.local/bin/mcp-atlassian" \
        --jira-url "$JIRA_URL" \
        --jira-username "$JIRA_USERNAME" \
        --jira-token "$JIRA_API_TOKEN" 2>/dev/null \
        && echo "  ✅ MCP jira registrado no Claude Code" \
        || echo "  ⏭  MCP jira já estava registrado"
    else
      echo "  ⏭  dados do Jira não informados — MCP não registrado"
    fi
  else
    echo "  ⏭  mcp-atlassian não encontrado — rode 'pipx install mcp-atlassian' antes de registrar o MCP jira"
  fi
else
  echo "  ⏭  Claude CLI não encontrado — MCPs não registrados"
fi

# 10. Criar diretório de logs se não existir
mkdir -p "$TOOLKIT/.logs"

echo ""
echo "✅ ia-toolkit-bootstrap configurado! Rode 'source ~/.zshrc' para ativar os aliases."
echo ""
echo "⚠️  Passos manuais que este script NÃO cobre (ver docs/CURRENT-SETUP.md):"
echo "   - 'claude login' se a sessão OAuth não tiver sido restaurada"
echo "   - copiar claude-md/workspace-CLAUDE.md para o diretório de trabalho principal"
echo "   - conferir permissões acumuladas em ~/.claude/settings.local.json (não versionadas)"
echo ""
echo "Aliases disponíveis:"
echo "  toolkit     → navega para $TOOLKIT"
echo "  tk-devops   → exibe persona DevOps Senior"
echo "  tk-sdd      → exibe persona SDD Expert"
echo "  tk-list     → lista prompts disponíveis"
echo "  tk-update   → git pull no toolkit"
echo "  tk-log      → monitora log de sessões"
