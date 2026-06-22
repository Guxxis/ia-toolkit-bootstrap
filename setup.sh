#!/bin/bash
# ia-toolkit setup — bootstrap para novo WSL
# Uso: bash ~/Workspace/ia-toolkit/setup.sh

set -e

TOOLKIT="$HOME/Workspace/ia-toolkit"
AGENTS_SKILLS="$HOME/.agents/skills"
BASHRC="$HOME/.bashrc"
ZSHRC="$HOME/.zshrc"

echo "🔧 Configurando ia-toolkit..."

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
  # Garante que o arquivo existe antes de checar/escrever
  touch "$rc_file"
  if ! grep -q "ia-toolkit/aliases.sh" "$rc_file"; then
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
  echo "  ✅ ~/.claude/settings.json atualizado com hooks"
else
  echo "  ⏭  ~/.claude/settings.json já customizado — merge manual necessário"
  echo "     Template disponível em: $TOOLKIT/settings/claude-settings.json"
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
