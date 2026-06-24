#!/bin/bash
# ia-toolkit-bootstrap setup — bootstrap para novo WSL
# Uso: bash ~/Workspace/ia-toolkit-bootstrap/setup.sh

set -e

TOOLKIT="$HOME/Workspace/ia-toolkit-bootstrap"
AGENTS_SKILLS="$HOME/.agents/skills"
BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"

echo "🔧 Configurando ia-toolkit-bootstrap..."

# 1. Garantir que a pasta de skills existe e criar symlinks
mkdir -p "$AGENTS_SKILLS"
for skill in "$TOOLKIT/skills/"*.md; do
  [ -f "$skill" ] || continue
  name=$(basename "$skill")
  if [ ! -L "$AGENTS_SKILLS/$name" ]; then
    ln -sf "$skill" "$AGENTS_SKILLS/$name"
    echo "  ✅ skill symlinked: $name"
  else
    echo "  ⏭  skill já existe: $name"
  fi
done

# 2. Source aliases no .bashrc e .zshrc (idempotente)
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

# 3. Aplicar settings do Claude Code (só se estiver no padrão mínimo ou inexistente)
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ ! -f "$CLAUDE_SETTINGS" ]; then
  mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
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

# 4. Registrar MCP do Obsidian no Claude Code
if command -v claude &> /dev/null; then
  if [ -z "$OBSIDIAN_API_KEY" ]; then
    echo ""
    echo "🔑 Para configurar o MCP do Obsidian, informe a API key:"
    read -rp "   OBSIDIAN_API_KEY: " OBSIDIAN_API_KEY
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
else
  echo "  ⏭  Claude CLI não encontrado — MCP não registrado"
fi

# 5. Criar diretório de logs se não existir
mkdir -p "$TOOLKIT/.logs"

echo ""
echo "✅ ia-toolkit-bootstrap configurado! Rode 'source ~/.zshrc' para ativar os aliases."
echo ""
echo "Aliases disponíveis:"
echo "  toolkit     → navega para $TOOLKIT"
echo "  tk-devops   → exibe persona DevOps Senior"
echo "  tk-sdd      → exibe persona SDD Expert"
echo "  tk-list     → lista prompts disponíveis"
echo "  tk-update   → git pull no toolkit"
echo "  tk-log      → monitora log de sessões"
