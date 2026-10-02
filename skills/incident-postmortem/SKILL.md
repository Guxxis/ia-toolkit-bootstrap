---
name: incident-postmortem
description: Fecha um incidente de servidor capturando todo o contexto gerado (comentários do card de origem e das subtasks, contexto das sessões), gerando o postmortem como .md no Drive via diagnostic-creator e postando o comentário final com resumo e link no card de origem. Use quando o usuário disser "incidente resolvido, faz o postmortem", "fecha o DOPS-XXX com postmortem", "encerra o incidente", ou quando o loop de execução do analista-de-incidentes terminar. Não fecha nem transiciona o card — isso é do usuário.
---

# Incident Postmortem

Fase de finalização do agente `analista-de-incidentes`.

## Passo 1: Capturar o contexto

- Card de origem com todos os comentários (`[Incidente] Fase: ...` e
  qualquer comentário humano).
- Todas as subtasks: status, descrição e comentários.
- Contexto desta sessão: comandos executados pelo usuário, saídas de
  validação, decisões tomadas na conversa.
- Se houver sessões anteriores do mesmo incidente, o card é a fonte — o que
  não foi registrado lá não é recuperável; aponte a lacuna em vez de
  supor.

## Passo 2: Montar a timeline e confirmar lacunas

Timeline em ordem: alerta do Zabbix → triagem → refinamento → cada etapa
executada → validação final/recovery. Calcule duração total e tempo até a
mitigação. Pergunte ao usuário, em uma única mensagem, só o que faltar:
impacto real (quem/quanto tempo), causa raiz confirmada, o que funcionou e
o que não funcionou.

## Passo 3: Gerar o arquivo via diagnostic-creator

Invoque a skill `diagnostic-creator` passando o contexto consolidado, a
chave do card de origem e o host. Ela gera o `.md`
`postmortem-[TASK-ID]-[HOST]-[PROBLEMA].md`, sobe na pasta `post-mortem`
do Drive e devolve o link. Garanta que o conteúdo inclua a timeline do
Passo 2 e a lista de subtasks com o resultado de cada uma.

## Passo 4: Comentário final

Via `incident-comment`, fase `Postmortem`:

- Resumo de 2-4 linhas (o que aconteceu, causa raiz, como foi resolvido).
- Duração e impacto.
- Ações preventivas em aberto (com responsável).
- Link do postmortem no Drive.

Disparado pela skill: mostre o rascunho e só poste depois do "ok" do
usuário. Depois de postar, lembre que fechar o card e as subtasks é com
ele.
