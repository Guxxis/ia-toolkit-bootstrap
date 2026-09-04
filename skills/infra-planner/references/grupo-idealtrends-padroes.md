# Padrões de Infra — Grupo Ideal Trends

Referência consolidada dos padrões e decisões de infra do grupo. Leia antes de fazer recomendações.

---

## Estratégias de deploy: quando usar cada uma

O grupo tem **duas estratégias de deploy** — escolha baseada no que o projeto já tem:

| Estratégia | Quando usar | Pipeline Jenkins |
|-----------|-------------|-----------------|
| **Docker Swarm** | Projeto já tem Dockerfile; ou está sendo containerizado agora; ou é um novo projeto que vai seguir o padrão moderno | `dockerSwarmPipeline` (a criar) |
| **Git-pull tradicional** | Projeto sem Dockerfile (Laravel, Node sem container); prioridade é velocidade; sem necessidade de isolamento agora | `laravelGitPullPipeline` (já existe) |

**Não force Docker Swarm em projetos sem Dockerfile** — a `laravelGitPullPipeline` já existe, funciona, e entrega em minutos. Containerizar do zero é trabalho de código, não só de infra.

---

## Ferramentas e stack padrão

| Camada | Ferramenta | Notas |
|--------|-----------|-------|
| Cloud | Digital Ocean | Team isolado por projeto (billing + token separados) |
| Orquestração (containerizado) | Docker Swarm single-node | `docker stack deploy` |
| Deploy tradicional | git-pull + systemd | `laravelGitPullPipeline`; Nginx/FrankenPHP no host |
| Orquestração (prod futura) | Kubernetes + AWS | Ainda não em uso; alvo de migração |
| Registry (se containerizado) | Bitbucket Container Registry (`crg.apkg.io`) | Auth Atlassian unificada; Jenkins já tem creds |
| CI/CD | Jenkins (no jumphost-core) | Shared-library em `pipeline-library/` |
| Segredos | Infisical (self-hosted no jumphost) | Universal Auth (client ID + secret) |
| Provisionamento | Terraform + Ansible | Modelo: `devops.jumphost` |
| Reverse proxy (swarm) | Traefik (swarm mode) | Let's Encrypt HTTP-01 |
| Reverse proxy (tradicional) | Nginx + Certbot | PHP-FPM ou FrankenPHP |
| Notificações CI | Google Chat + e-mail | Webhooks já configurados no Jenkins |
| Status build | Bitbucket Build Status API | `sendBitbucketStatus` na shared-lib |
| Rastreamento | Jira (idealtrends.atlassian.net) | `jiraSendDeploymentInfo` na shared-lib |

---

## Arquitetura de rede do jumphost (padrão NÃO seguido em homolog)

O jumphost-core **não tem inbound TCP**: acesso SSH via Tailscale, HTTP/HTTPS via Cloudflare Tunnel. Sem porta 22 exposta publicamente.

Para ambientes de **homolog de novos projetos**, a decisão atual é usar **SSH direto** (porta 22 restrita a IPs admin) para velocidade de implementação. Cloudflare Tunnel + Tailscale podem ser adicionados depois.

---

## Modelo de repositório de infra

Cada projeto com infra própria tem um repo `devops.<projeto>` que espelha a estrutura do `devops.jumphost`:

```
devops.<projeto>/
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example   # sem valores reais
│   ├── main.tf                    # VPC, droplet, firewall, reserved IP, dados gerenciados
│   └── outputs.tf
├── ansible/
│   ├── inventory.ini
│   ├── playbook.yml
│   ├── roles/
│   │   ├── hardening/
│   │   ├── swap/
│   │   ├── docker/
│   │   └── traefik/               # com Let's Encrypt
│   └── vars/
│       └── secrets.yml.example
└── README.md
```

Roles disponíveis no modelo jumphost: `hardening`, `swap`, `tailscale`, `cloudflare`, `docker`, `traefik`, `jenkins`, `grafana`, `infisical`, `zabbix`.

Para homolog de projetos: usar `hardening`, `swap`, `docker`, `traefik`. Omitir `tailscale` e `cloudflare` na primeira implantação.

---

## Padrão de provisionamento Terraform (Digital Ocean)

**Antes de propor o `ip_range`:** não assuma um CIDR "livre" baseado só no que está documentado em repos locais ou no vault — cada empresa/produto do grupo tem team/token próprio na Digital Ocean, e documentação local fica desatualizada ou nunca existiu para decisões tomadas direto no console. Rode `doctl vpcs list` (com o token do team certo) ou peça print do dashboard DO antes de fechar qualquer range — Terraform só mostra o que foi aplicado por aquele código, não o que outro time criou manualmente ou por outro repo/team.

```hcl
# VPC isolada por projeto
resource "digitalocean_vpc" "<projeto>_vpc" {
  name     = "vpc-<projeto>"
  region   = var.region           # default: nyc3
  ip_range = "10.X.0.0/24"       # range único por projeto — confirmado via doctl vpcs list, não só por ausência de menção em repo/vault
}

# Droplet
resource "digitalocean_droplet" "<projeto>_droplet" {
  image      = "ubuntu-24-04-x64"
  name       = "<projeto>-homolog"
  region     = var.region
  size       = var.droplet_size   # default homolog: s-2vcpu-4gb
  monitoring = true
  backups    = true
  vpc_uuid   = digitalocean_vpc.<projeto>_vpc.id
  ssh_keys   = [var.ssh_key_id]
  tags       = ["idealtrends", "<projeto>", "homolog"]
}

# IP Fixo
resource "digitalocean_reserved_ip" "<projeto>_ip" { region = var.region }
resource "digitalocean_reserved_ip_assignment" "<projeto>_ip_assign" {
  ip_address = digitalocean_reserved_ip.<projeto>_ip.ip_address
  droplet_id = digitalocean_droplet.<projeto>_droplet.id
}

# Firewall (homolog com SSH exposto)
resource "digitalocean_firewall" "<projeto>_fw" {
  name        = "firewall-<projeto>"
  droplet_ids = [digitalocean_droplet.<projeto>_droplet.id]

  inbound_rule { protocol = "icmp"; source_addresses = ["0.0.0.0/0", "::/0"] }
  inbound_rule { protocol = "tcp"; port_range = "22"; source_addresses = [var.admin_ips] }
  inbound_rule { protocol = "tcp"; port_range = "80"; source_addresses = ["0.0.0.0/0", "::/0"] }
  inbound_rule { protocol = "tcp"; port_range = "443"; source_addresses = ["0.0.0.0/0", "::/0"] }

  outbound_rule { protocol = "tcp";  port_range = "1-65535"; destination_addresses = ["0.0.0.0/0", "::/0"] }
  outbound_rule { protocol = "udp";  port_range = "1-65535"; destination_addresses = ["0.0.0.0/0", "::/0"] }
  outbound_rule { protocol = "icmp"; destination_addresses = ["0.0.0.0/0", "::/0"] }
}
```

---

## Registry: Bitbucket Container Registry

Endpoint: `crg.apkg.io`
Workspace: `idealtrends`

```bash
# Token escopado: read:package:bitbucket + write:package:bitbucket
docker login crg.apkg.io -u <email_atlassian>

docker build -t crg.apkg.io/idealtrends/<projeto>-backend:<tag> .
docker push  crg.apkg.io/idealtrends/<projeto>-backend:<tag>
```

Jenkins já tem credencial `bitbucket-api-creds` — reusar para registry.

---

## Injeção de env no Swarm

`docker stack deploy` ignora `env_file`, `depends_on` (condition), `container_name` e `build`.

**Fluxo padrão (1ª implantação — velocidade):**
1. Jenkins autentica no Infisical (env `homolog`) e exporta dotenv
2. Grava `/opt/<projeto>/homolog.env` no droplet (perm 600)
3. Deploy: `set -a; . /opt/<projeto>/homolog.env; set +a; docker stack deploy -c stack.yml <projeto>`

**Hardening futuro:** mover sensíveis para Docker secrets + entrypoint shim. Não é obrigatório na 1ª implantação.

---

## Pipeline Jenkins (dockerSwarmPipeline — padrão a criar)

A shared-library não tem ainda a var `dockerSwarmPipeline`. Deve seguir o modelo do `nodeGitPullPipeline` com adaptações:

**Estágios:**
1. Configuração (branch check, Infisical, Bitbucket status)
2. Checkout
3. Build da imagem (`docker build --target production`)
4. Tag (`sha-<commit>` + nome do ambiente)
5. Push para `crg.apkg.io`
6. Env: exportar Infisical → `.env` no droplet
7. Deploy: SSH → `docker stack deploy --with-registry-auth`
8. Migrations (se aplicável — one-shot antes do health check)
9. Health check
10. Limpeza
11. Rollback (parâmetro `RUN_ROLLBACK` → `docker service rollback`)

Mapear: `develop → homolog`, `main → prod`.

---

## Stack file de Swarm (docker-stack.homolog.yml)

Derivado do `docker-compose.staging.yml` mas com:
- Imagem do Bitbucket Registry (não build local)
- Sem serviços de suporte que viram gerenciados (postgres, redis, minio)
- `restart:` → `deploy.restart_policy:`
- `depends_on:` removido (usar `healthcheck` + `update_config`)
- `container_name:` removido
- Bloco `deploy:` com `replicas`, `update_config`, `resources`
- Serviço Traefik (swarm provider) com labels de roteamento por Host

---

## Convenções de nomenclatura

| Item | Padrão |
|------|--------|
| Repo de infra | `devops.<projeto>` |
| VPC | `vpc-<projeto>` |
| Droplet | `<projeto>-homolog` |
| Domínio homolog app | `homolog-app.<projeto>.com.br` |
| Domínio homolog api | `homolog-api.<projeto>.com.br` |
| Imagens Bitbucket | `crg.apkg.io/idealtrends/<projeto>-backend` e `-frontend` |
| Pasta vault | `40_Projetos/<NomeProjeto>/` |
| Notas vault | `<NomeProjeto>-Guide.md` e `<NomeProjeto>-Checklist.md` |
| Ansible env file | `/opt/<projeto>/homolog.env` |

---

## Dados gerenciados vs. self-hosted

| Contexto | Recomendação |
|----------|-------------|
| Homolog (PoC, custo baixo) | Self-hosted no Swarm (Postgres, Redis, MinIO como services) |
| Homolog (realismo de prod) | DO Managed PG + Redis + Spaces |
| Produção | AWS RDS + ElastiCache + S3 |

Para decidir, perguntar ao usuário: precisa de isolamento/realismo ou quer velocidade e custo baixo?

---

## Bandeiras de atenção comuns

| Padrão no código | Problema | Ação |
|-----------------|---------|------|
| `ARG NEXT_PUBLIC_*` no Dockerfile | URL baked em build-time → imagem homolog ≠ prod se quiser mesma imagem. **Não há alternativa dentro da mesma imagem** — runtime-env é obrigatório, não opcional | Migrar para runtime-env antes de provisionar; se preferir builds separados por ambiente, documentar explicitamente que homolog ≠ prod |
| `ARG VITE_*` no Dockerfile | Mesmo problema em apps Vite | Idem |
| `npm ci --only=production` | Deprecado | Trocar por `npm ci --omit=dev` |
| `depends_on: condition: service_healthy` | Ignorado no Swarm | Estratégia de retry ou healthcheck no serviço |
| Env vars divergentes entre compose files | Contrato inconsistente | Normalizar antes de montar stack |
| Chromium/Puppeteer na imagem | +300MB; aceitável agora | Avaliar worker dedicado no futuro |
| Sem Dockerfile em projeto PHP/Node | Projeto não está containerizado | Perguntar ao usuário: containerizar agora (trabalho de código) ou usar `laravelGitPullPipeline` (mais rápido)?  |

## `laravelGitPullPipeline` — deploy tradicional

Shared-library já existente em `pipeline-library/vars/laravelGitPullPipeline.groovy`. Funciona para projetos PHP/Node sem Docker:

- **Fluxo:** git clone/pull → composer install / npm install + build → migrations → symlink para `current/` → reload serviços
- **Servidor:** PHP-FPM ou FrankenPHP + Nginx; serviços systemd (Horizon, Reverb, Octane, etc.) via `deploy.sh` customizado
- **Segredos:** `.env` compartilhado em `shared/` entre releases (via Infisical → Jenkins → SSH)
- **Rollback:** `runRollback` reverte o symlink `current/` para a release anterior
- **Estrutura de diretórios no servidor:**
  ```
  /home/<user>/web/<dominio>/
    releases/           ← releases versionadas (mantém as 3 últimas)
    shared/
      .env              ← env compartilhado, não commitado
    current -> releases/<ts>  ← symlink atômico
    public_html -> current/dist (ou public/)
  ```
- **`deploy.sh`** na raiz do repo: customizado por projeto. O pipeline-library executa este script dentro da release.

**Gerenciamento de processos long-running (Horizon/Reverb):** `pm2` é legado no grupo — usado pontualmente em pipelines antigas, não é mais o padrão, mesmo que algum `deploy.sh` mais antigo ainda o referencie. Padrão atual é `supervisor`:
- Horizon: `php artisan horizon:terminate` no deploy (sem sudo; supervisor respawna o processo).
- Reverb: `sudo supervisorctl restart <grupo>:<reverb>` (1 linha de sudoers).
- Scheduler: cron do usuário (`schedule:run` a cada minuto), não supervisor.
- `.conf` do supervisor aponta para o symlink `current` (nunca para uma release absoluta); versionar em `deploy/supervisor/` no repo do projeto e, idealmente, no Ansible da frota.
