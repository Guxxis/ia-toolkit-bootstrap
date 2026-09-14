#!/bin/bash
# ia-toolkit-bootstrap aliases — source este arquivo no .bashrc

export TOOLKIT="$HOME/workspace/ia-toolkit-bootstrap"
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
export PATH="$HOME/.local/bin:$PATH"

alias toolkit="cd $TOOLKIT"
alias tk-update="cd $TOOLKIT && git pull && echo '✅ toolkit atualizado'"
alias tk-setup="ansible-playbook $TOOLKIT/playbook.yml"
alias tk-log="tail -f $TOOLKIT/.logs/sessions.log"

# Exibe persona no terminal (use para copiar e colar no agente)
alias tk-devops="cat $TOOLKIT/prompts/devops_senior.md"
alias tk-sdd="cat $TOOLKIT/prompts/sdd_expert.md"

# Lista prompts disponíveis
alias tk-list="ls $TOOLKIT/prompts/ | sed 's/.md//'"

# Remonta o Google Drive (G:) quando o mount drvfs cai (ENODEV) — comum após sleep/resume do Windows
gmount() {
  echo "🔄 Remontando /mnt/g..."
  sudo umount /mnt/g 2>/dev/null
  if sudo mount /mnt/g && ls "/mnt/g/Meu Drive" >/dev/null 2>&1; then
    echo "✅ /mnt/g remontado e acessível."
  else
    echo "❌ Falha ao remontar /mnt/g — confira se o Google Drive está aberto e sincronizado no Windows." >&2
    return 1
  fi
}
