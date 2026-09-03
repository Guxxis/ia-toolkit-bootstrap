---
name: feedback-prefer-ansible-over-manual-fixes
description: "When fixing infra issues found via direct SSH diagnosis, land the persistent fix in Ansible, not as a manual one-off edit on the server"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 92eb7d00-94f4-4bb4-b226-4835436fc70a
---

Manual SSH edits (sed on config files, DB updates, etc.) are fine for diagnosis and unblocking an urgent test, but the durable fix must be authored back into the relevant Ansible role/playbook — not left as a manual change sitting only on the live server.

**Why:** confirmed explicitly during the IDEALPLUS02 API auth/timeout debugging session (2026-07-10) — after I fixed several things directly via SSH (hestia.conf API_SYSTEM, .env HORIZON_TIMEOUT_WORDPRESS_INSTALL, API scope command name for install-wp-tema) and offered to also update the Ansible role, the user said "não mexe nos scripts agora" then "apenas tenha esse contexto e se for para alterar algo, que seja no ansible" — i.e., don't touch things ad hoc; any future change should go through Ansible, not a fresh manual edit.

**How to apply:** when live-debugging [[project_devops43]]-scope infra (ansible-wordpress, ansible-sistema, or similar IaC-managed repos), it's OK to SSH in and test/patch live to confirm a hypothesis or unblock the user's immediate test. But before considering the work "done," either (a) port the change into the corresponding Ansible role/template/defaults myself, or (b) explicitly ask the user whether they want it ported to Ansible now or later — don't just leave it as an undocumented manual drift from IaC. Do not proactively touch scripts/config again without being asked, per the immediate instruction to pause after the install-wp-tema fix.
