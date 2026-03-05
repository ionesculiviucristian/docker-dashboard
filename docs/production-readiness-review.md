# Analiză avansată Docker / Compose — `docker-dashboard`

> Review pentru evaluarea production-readiness într-un context de firmă mică.
> Data: 2026-05-25

## Verdict scurt

**Pentru o firmă mică în producție: 60% gata.** Setup-ul are oase bune (network segmentation, healthchecks, resource limits, Traefik+Authentik centralizat, Prometheus+Loki+Alloy stack complet), dar are **5 blocker-e** care îl țin clar în zona "lab/dev pentru un developer", nu producție.

Cu 1-2 zile de muncă pe lista de blockere, plus 3-5 zile pe partea de hardening, devine deployabil într-o firmă mică.

---

## ✅ Ce e făcut corect (chestii care lipsesc adesea, dar tu le ai)

1. **Network segmentation pe serviciu** (`${POSTGRES_NETWORK}`, `${MONGO_NETWORK}` etc.) + rețele `proxy` și `prometheus` separate. Foarte bine.
2. **`${VAR:?err}` peste tot** — fail-fast la variabile lipsă. Excelent.
3. **Versionare strictă pe imagini** (singura excepție: `it-tools:latest`).
4. **Healthchecks** pe quasi-toate serviciile cu `start_period` + `retries` rezonabile.
5. **Resource limits** (`cpus` + `memory`) pe TOATE — preventiv pt fork-bombs / memory leaks.
6. **`security_opt: no-new-privileges:true`** aproape peste tot.
7. **`restart: unless-stopped`** uniform.
8. **Read-only mounts** pentru config (`:ro`).
9. **`depends_on` cu `condition: service_healthy`** la phpmyadmin, pgadmin, mongo-express, exporters — corect.
10. **Auth centralizat** prin Authentik forwardAuth middleware @ Traefik.
11. **Pinning versiuni cu regex WUD** (`wud.tag.include: "^\\d+\\.\\d+\\.\\d+$$"`) — bine făcut, evită prereleases.
12. **Imagini Mongo & Mongo-express scrub bine** cu replica set + keyfile.
13. **Loki + Alloy + Prometheus + cAdvisor + Node-exporter + DB-exporters** — stack de observability complet.

---

## 🔴 BLOCKER-e critice (până le rezolvi, NU în producție)

### B1. Parole — o singură parolă slabă reutilizată
`SERVICES_USER_PASSWORD="1q2W3e4r5T6y"` e injectată în **15+ servicii** (postgres, mysql, mongo root, mongo exporter, redis, rabbitmq, grafana admin, pgadmin, ntfy, seaweedfs S3, authentik bootstrap, mealie, etc.). În prod:
- O singură parolă compromisă = totul compromis.
- Fiecare serviciu trebuie să-și aibă parola sa, generată cu `openssl rand -base64 32`.
- Mută în secrets manager real: Bitwarden (deja ai integrarea!) sau Docker secrets / Vault.

### B2. Secret committed în repo: `services/mongo/keyfile`
Verifică `services/mongo/.gitignore` — fișierul `keyfile` (cu `chmod 400`) **nu apare ignorat**. Dacă a fost vreodată commit-uit, e public. Rotește-l acum + adaugă-l în `.gitignore` + folosește `keyfile` generat la prima rulare în `deploy.py`.

### B3. `.env` cu secrete reale + permisiuni 644
`.env` conține `AUTHENTIK_SECRET_KEY`, `AUTHENTIK_BOOTSTRAP_TOKEN`, `OLLAMA_OPEN_WEBUI_WEBUI_SECRET_KEY` în clar. Permisiuni `644` (`ls -la .env`) — orice user de pe host poate citi. `chmod 600 .env` + scoate aceste valori din `.env.example` (ai făcut deja bine pentru example).

### B4. `docker.sock` montat în 6+ containere — suprafață de atac uriașă
- `authentik-worker`: socket **RW + `user: root`** — ESCALADARE TRIVIALĂ la host root. Mută integrarea Docker pe **docker-socket-proxy** (Tecnativa) și expune doar endpoint-urile necesare (`/containers/json`, `/images/json`).
- `dozzle`, `homepage`, `whatsupdocker`, `grafana-alloy`, `cadvisor` — toate RO, OK, dar în prod tot prin proxy.
- `cadvisor: privileged: true` — necesar funcțional, izolează-l pe o rețea dedicată.

### B5. Lipsește orice backup automat
Nu există job pentru: postgres dump, mysql dump, mongo dump, volume snapshot, configuri Grafana/Authentik. Pentru firmă **e obligatoriu**:
- `pg_dump` cron → SeaweedFS S3 → retention 30 zile
- `mongodump` cron
- `mysqldump --single-transaction`
- Authentik blueprints export (deja le ai în `blueprints/`)
- Soluție recomandată: container `offen/docker-volume-backup` sau `restic` cron job

---

## 🟠 Probleme medii (de rezolvat înainte de prod)

### Securitate la nivel de proxy
- **Traefik `--api.insecure=true` + portul `8080:8080` expus pe host** — chiar dacă routa `/dashboard` are middleware Authentik, portul 8080 e direct accesibil pe host. În prod: `--api.insecure=false` + acces doar prin Traefik HTTPS cu auth.
- **Lipsă HSTS / security headers global**: niciun middleware Traefik pentru `Strict-Transport-Security`, `X-Frame-Options`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin`. Soluție: middleware `headers` în `services/traefik/config/tls.yml`.
- **Lipsă rate-limit**: nicio protecție DoS pe rute publice. Adaugă middleware `rateLimit`.
- **TLS minVersion / cipher suites nesetate** în `tls.yml` — folosește defaults Traefik care includ și ciphers vechi. Forțează `minVersion: VersionTLS12` + `cipherSuites` whitelist.
- **mkcert** OK pentru `.local`; pentru prod (chiar și internă) trecere la **Let's Encrypt + ACME DNS challenge** pentru wildcard, sau Step CA intern.

### Authentik
- **Lipsă Redis** — Authentik **necesită Redis** începând cu 2024.10 ca broker pentru worker. Stack-ul actual rulează **fără** Redis în rețeaua Authentik. Verifică logs `authentik-worker` — probabil dă warning sau folosește un fallback fragil. Adaugă serviciu `authentik-redis` în compose.
- **`authentik-worker: user: root`** — necesar doar dacă Docker integration e activ; restrânge cu socket-proxy.
- **`AUTHENTIK_BOOTSTRAP_TOKEN` folosit ca admin token în Homepage** — token cu privilegii max. Creează în Authentik un service account dedicat pentru Homepage cu permisiuni read-only.
- **Lipsă `AUTHENTIK_ERROR_REPORTING__ENABLED=false`** (opt-out telemetry).

### Database hardening
- **PostgreSQL**: `sslmode=disable` pe exporter; lipsă `pg_hba.conf` custom; lipsă `shared_preload_libraries=pg_stat_statements`; `shm_size=256m` mic pentru workloads serioase.
- **MySQL**: rulează cu config default — fără `my.cnf` (no `innodb_buffer_pool_size` tunat, `max_connections=151` default). Lipsesc `MYSQL_DATABASE` + `MYSQL_USER` (aplicațiile vor folosi root).
- **MongoDB**: replica set inițializat manual? `mongod --replSet rs0` e setat dar `rs.initiate()` nu apare în `initdb/`. Fără el, replica set rămâne neinitializat → write-uri eșuează în anumite drivere.
- **Redis**: folosește `--requirepass` (legacy). Pentru Redis 7+ recomandat ACL via `users.acl` cu user per consumer + permisiuni granulare. Lipsește `--maxmemory` + `--maxmemory-policy allkeys-lru` (poate ocupa toată RAM-ul).
- **RabbitMQ**: zero config persistat (`definitions.json`), zero exchange/queue declarate la pornire, fără `rabbitmq.conf` custom. Pentru prod: management plugin + definitions auto-load.

### n8n — multiple probleme
1. **Lipsă `N8N_ENCRYPTION_KEY`** — fără ea, n8n generează una random la primul start și **dacă pierzi volumul, toate credentialele cifrate sunt nerecuperabile**.
2. **Lipsă `N8N_HOST` + `N8N_PROTOCOL=https` + `WEBHOOK_URL`** — webhook-urile vor fi cu URL greșit.
3. **Backend SQLite** (default) — pt prod schimbă pe Postgres extern (`DB_TYPE=postgresdb`).
4. **Lipsă auth nativă** — depinde 100% de Authentik forwardAuth; dacă Authentik cade, n8n e neexpus (BINE de fapt, deoarece router-ul nu funcționează). Dar API-ul intern e accesibil din rețea fără auth.
5. **Lipsă `N8N_RUNNERS_ENABLED=true`** — task runners e best practice n8n 2024+.

### Open WebUI / Ollama
- `WEBUI_AUTH: false` — utilizatorii sunt "anonymous". Conversațiile / RAG-urile nu sunt izolate. Activează `WEBUI_AUTH: true` + OIDC către Authentik.
- `extra_hosts: host.docker.internal:host-gateway` — periculos dacă deschizi serviciul. OK în rețeaua internă, dar de evitat.

### Dozzle
- `ENABLE_ACTIONS: true` + `ENABLE_SHELL: true` = utilizatorii pot porni/opri containere **și deschide shell în orice container**. Forțează `DOZZLE_AUTH_PROVIDER=simple` cu users dedicați (`/data/users.yml`) sau OIDC către Authentik, nu doar forwardAuth.

### Mongo-express
- `ME_CONFIG_BASICAUTH: false` — protejat doar de Authentik forwardAuth. Dacă Authentik e jos, e deschis. Activează basicauth ca strat al 2-lea.

### SeaweedFS
- Singur serviciu **fără** `security_opt: no-new-privileges:true` — inconsistent.
- `s3.json` cu credențiale plaintext în repo + parola default.
- Rulează single-node fără replicare (`master + volume + filer + s3` într-un proces). Pentru prod: pornește separat cu `-replication=001`.

### Logging
- **Niciun `logging:` driver configurat** — toate folosesc `json-file` default fără rotație. Disk-ul se umple inevitabil. Adaugă **global** (în fiecare serviciu sau via `default` în compose):
  ```yaml
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"
  ```

### Loki
- Rulează cu `local-config.yaml` (filesystem). Fără retention policy → disk se umflă.
- Pentru prod: chunk storage → SeaweedFS S3; retention `compactor` setat la 30-90 zile.

### Prometheus
- Fără retention configurat (default 15d, fără remote write).
- **Fără alerting** — nicio regulă, niciun Alertmanager. Pentru prod adaugă Alertmanager → ntfy (deja îl ai!).
- Scrape `n8n:5678/metrics` — verifică că endpoint-ul nu necesită auth; dacă da, nu vor fi metrici.

---

## 🟡 Hardening recomandat (production-grade)

| Categorie | Recomandare |
|---|---|
| **Capabilities** | Adaugă `cap_drop: [ALL]` + `cap_add: [NET_BIND_SERVICE]` (sau ce e necesar) la fiecare serviciu |
| **Read-only rootfs** | `read_only: true` + `tmpfs: /tmp` pentru it-tools, omni-tools, exporters, whoami, mailpit |
| **User non-root** | Forțează `user: "1000:1000"` unde imaginea suportă (postgres, redis, n8n, grafana — Grafana rulează deja non-root) |
| **`init: true`** | Doar pe ntfy — adaugă pe n8n, ollama, open-webui (zombie reaping) |
| **Docker socket proxy** | Înlocuiește mounturile directe `docker.sock` cu `tecnativa/docker-socket-proxy` (read-only API endpoints) |
| **SBOM / scan** | Adaugă `trivy image` în CI pentru toate imaginile pinned |
| **`${PWD}` în volume** | Schimbă pe `./services/...` (relative paths) — `${PWD}` se rupe dacă rulezi din alt director |
| **AppArmor / SELinux** | `security_opt: ["apparmor:docker-default"]` explicit |
| **Backups** | Container `offen/docker-volume-backup` cu schedule cron + sync → SeaweedFS |
| **Secrets management** | Treci pe **Docker secrets** sau Vault; `.env` cu parole în clar e antipattern în prod |
| **Healthcheck Traefik whoami, cadvisor, mailpit, ollama-open-webui, n8n** | nu au — adaugă |
| **Alertmanager** | + rules pentru: container down, disk usage, mem usage, postgres lag, mysql slow queries, ntfy push |
| **Reverse proxy WAF** | Pentru prod cu acces extern: CrowdSec bouncer la Traefik |
| **Watchtower / WUD auto-update** | Acum doar notifică (OK pentru control); pentru prod **menține** asta, dar adaugă pipeline staging |

---

## 📋 Checklist prioritizat (în ordinea acțiunii)

**Săptămâna 1 — blockers:**
1. ☐ Rotește toate parolele; generează câte una per serviciu (script: `openssl rand -base64 24`)
2. ☐ `chmod 600 .env .env.custom`; mută secretele în Bitwarden (ai deja flow-ul `dashboard.py import-secrets`)
3. ☐ Rotește `mongo/keyfile`, adaugă în `.gitignore`, generează la deploy
4. ☐ Adaugă **Redis** la stack-ul Authentik (e obligatoriu din 2024.10)
5. ☐ Înlocuiește mount-uri directe `docker.sock` cu **tecnativa/docker-socket-proxy** (mai ales pe authentik-worker)
6. ☐ Setează `chmod 0700` pe certs/, scoate `--api.insecure=true` din Traefik, închide portul `8080`
7. ☐ Backup automat (postgres, mysql, mongo) → SeaweedFS (container `offen/docker-volume-backup`)

**Săptămâna 2 — hardening:**
8. ☐ Middleware Traefik global: HSTS + security headers + rateLimit + TLS minVersion 1.2
9. ☐ `logging: { driver: json-file, options: { max-size: 10m, max-file: 3 } }` peste tot
10. ☐ Loki retention + chunks pe SeaweedFS S3
11. ☐ Prometheus retention + Alertmanager → ntfy
12. ☐ n8n: `N8N_ENCRYPTION_KEY` + Postgres backend + `N8N_HOST/PROTOCOL/WEBHOOK_URL`
13. ☐ Dozzle: auth nativă, dezactivează `ENABLE_SHELL` (sau cere RBAC)
14. ☐ Open WebUI: `WEBUI_AUTH=true` + OIDC către Authentik
15. ☐ MongoDB: script `rs.initiate()` în initdb
16. ☐ Redis: `--maxmemory 400mb --maxmemory-policy allkeys-lru` + migrare la ACL

**Săptămâna 3 — operațional:**
17. ☐ Toate compose-urile: `cap_drop: [ALL]`, `read_only: true` unde se poate
18. ☐ Rute `services/` din `${PWD}` în `./`
19. ☐ MySQL: `my.cnf` custom + creare DB+user dedicat (nu root)
20. ☐ RabbitMQ: `definitions.json` + `rabbitmq.conf` mountate
21. ☐ Trivy/Grype scan pe imagini în CI
22. ☐ Documentație runbook (`docs/`): recovery DB, rotație secrete, incident response

---

## Concluzie

Stack-ul tău e **scris cu disciplină** — se vede experiența: convenții uniforme, fail-fast pe env, segmentare de rețea, observability completă, automation via Python bootstrap. Lipsesc însă **lucrurile care contează doar când ceva merge prost în prod**: backup, alerting, secrets management, rotation, defense-in-depth (auth nativă peste forwardAuth), capability drop, logging rotation.

Pentru o firmă mică (10-30 angajați, intern, fără acces de pe internet): **cu blockerele de mai sus rezolvate, e gata**. Pentru o firmă mică cu expunere internet sau date sensibile: adăugă și partea de hardening (săptămâna 2-3).
