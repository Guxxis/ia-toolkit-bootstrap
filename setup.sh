#!/bin/bash
# ia-toolkit setup — bootstrap para novo WSL
# Uso: bash ~/Workspace/ia-toolkit/setup.sh

set -e

TOOLKIT="$HOME/Workspace/ia-toolkit"
AGENTS_SKILLS="$HOME/.agents/skills"
BASHRC="$HOME/.bashrc"

echo "🔧 Configurando ia-toolkit..."

# 1. Symlink de skills do toolkit para ~/.agents/skills
if [ -d "$AGENTS_SKILLS" ]; then
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
else
  echo "  ⚠️  ~/.agents/skills não encontrado — skills não foram symlinked"
fi

# 2. Source aliases no .bashrc (idempotente)
if ! grep -q "ia-toolkit/aliases.sh" "$BASHRC"; then
  echo "" >> "$BASHRC"
  echo "# ia-toolkit" >> "$BASHRC"
  echo "source $TOOLKIT/aliases.sh" >> "$BASHRC"
  echo "  ✅ aliases adicionados ao .bashrc"
else
  echo "  ⏭  aliases já estão no .bashrc"
fi

# 3. Aplicar settings do Claude Code (só se estiver no padrão mínimo)
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ -f "$CLAUDE_SETTINGS" ]; then
  current=$(cat "$CLAUDE_SETTINGS")
  if [ "$current" = '{"theme": "dark"}' ] || [ "$current" = '{"theme":"dark"}' ]; then
    cp "$TOOLKIT/settings/claude-settings.json" "$CLAUDE_SETTINGS"
    echo "  ✅ ~/.claude/settings.json atualizado com hooks"
  else
    echo "  ⏭  ~/.claude/settings.json já customizado — merge manual necessário"
    echo "     Template disponível em: $TOOLKIT/settings/claude-settings.json"
  fi
fi

# 4. Criar diretório de logs se não existir
mkdir -p "$TOOLKIT/.logs"

echo ""
echo "✅ ia-toolkit configurado! Rode 'source ~/.bashrc' para ativar os aliases."
echo ""
echo "Aliases disponíveis:"
echo "  toolkit     → navega para $TOOLKIT"
echo "  tk-devops   → exibe persona DevOps Senior"
echo "  tk-sdd      → exibe persona SDD Expert"
echo "  tk-list     → lista prompts disponíveis"
echo "  tk-update   → git pull no toolkit"
echo "  tk-log      → monitora log de sessões"
