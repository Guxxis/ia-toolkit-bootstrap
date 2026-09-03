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
