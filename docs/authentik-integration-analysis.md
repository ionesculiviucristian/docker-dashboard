# Integrare Authentik — analiză pe servicii

> Care servicii din stack pot fi integrate cu Authentik (2026.5.0), per protocol nativ vs forwardAuth proxy.
> Data: 2026-05-25

## 📊 Sumar numeric

- **Servicii cu login propriu (obligatoriu sau opțional):** **13**
- **Pot fi mutate 100% pe Authentik OIDC:** **6** (gratis) + **1** (n8n, doar cu Enterprise)
- **Rămân pe login propriu (sau forwardAuth doar):** **6**

---

## 🟢 OIDC nativ — recomand migrare de pe forwardAuth (sau "fără auth")

Aceste servicii au suport **OIDC/OAuth2 build-in**. ForwardAuth e doar un patch peste lipsă de auth — cu OIDC nativ obții: user identity, role mapping, group-based RBAC, session management propriu.

**Legendă status actual:**
- 🔵 **Admin local** = serviciul are user/parolă proprie definite în env (ex: `GF_SECURITY_ADMIN_USER`); router-ul Traefik **nu** are middleware Authentik forwardAuth — fiecare user are propriul cont local
- 🟡 **forwardAuth** = router-ul Traefik are middleware `authentik-server@docker`; userul autentificat la Authentik primește acces, dar app-ul nu știe cine e (sau o știe doar din header dacă e configurat)

| # | Serviciu | Status actual | Migrare | Beneficii |
|---|---|---|---|---|
| 1 | **Grafana** | 🔵 Admin local (`GF_SECURITY_ADMIN_USER`), **fără** middleware Authentik | `GF_AUTH_GENERIC_OAUTH_*` env vars — **GRATUIT** (README zice "paid OIDC" dar e info învechit) | Roles din `entitlements` claim, auto-provision users, înlocuiește admin local |
| 2 | **pgAdmin4** | 🔵 Admin local (`PGADMIN_DEFAULT_EMAIL`), **fără** middleware Authentik | `OAUTH2_CONFIG` + `AUTHENTICATION_SOURCES=['oauth2','internal']` | Provisionare automată cu `OAUTH2_AUTO_CREATE_USER`, înlocuiește admin local |
| 3 | **RabbitMQ** | 🔵 Admin local (`RABBITMQ_DEFAULT_USER`), **fără** middleware Authentik | Plugin `rabbitmq_auth_backend_oauth2` + `management.oauth_enabled=true` | Permisiuni granulare per group (`rabbitmq-administrator`, `rabbitmq-monitoring`) |
| 4 | **Open WebUI** | 🟡 forwardAuth + `WEBUI_AUTH=false` (anonymous) | `OAUTH_CLIENT_ID`, `OPENID_PROVIDER_URL`, `WEBUI_AUTH=true` | Conversații/RAG izolate per user, audit log |
| 5 | **Mealie** (custom) | 🔵 Admin local (sign-up form la prima rulare), **fără** middleware Authentik | `OIDC_AUTH_ENABLED=true`, `OIDC_CONFIGURATION_URL`, `OIDC_USER_GROUP`, `OIDC_ADMIN_GROUP` | Group-based access |
| 6 | **What's Up Docker** | 🟡 forwardAuth (fără auth nativă activată) | `WUD_AUTH_OIDC_AUTHENTIK_DISCOVERY`, `WUD_AUTH_OIDC_AUTHENTIK_CLIENTID`, etc. | Auth nativă peste forwardAuth (defense-in-depth) |
| 7 | **Dozzle** | 🟡 forwardAuth (fără auth nativă activată) | `DOZZLE_AUTH_PROVIDER=forward-proxy` + `DOZZLE_AUTH_HEADER_USER=X-authentik-username` | Dozzle primește user identity din header → poate face RBAC pe `ENABLE_SHELL` |

**Notă pentru Dozzle**: în prezent middleware-ul injectează header-ele `X-authentik-*`, dar Dozzle nu le folosește (auth provider nu e setat). Setând `forward-proxy`, Dozzle știe cine e user-ul și poate aplica RBAC granular.

---

## 🟡 OIDC posibil dar cu restricții — păstrează forwardAuth deocamdată

| # | Serviciu | De ce nu e ideal acum |
|---|---|---|
| 1 | **n8n** | OIDC e **Enterprise-only license** (din v2.18.0). Alternative: stay forwardAuth, sau folosește `n8n-oidc` (third-party proxy, neoficial). **Recomandare**: forwardAuth + `N8N_BASIC_AUTH_ACTIVE=true` ca fallback |
| 2 | **phpMyAdmin** | Are auth `signon` plugin dar configurarea e complexă (necesită un script PHP custom care primește SSO token). Cost/benefit slab — păstrează forwardAuth |
| 3 | **mongo-express** | Doar basic auth nativ; nu suportă OIDC. Activează `ME_CONFIG_BASICAUTH=true` ca strat secundar peste forwardAuth |
| 4 | **Mailpit** | Doar basic auth (`MP_UI_AUTH_FILE`). ForwardAuth e suficient pentru dev/intern |

---

## 🔴 Doar forwardAuth (Proxy Outpost) — nu au alternativă nativă

Acestea nu au și **nu vor avea** OIDC nativ — sunt fie unelte fără concept de user (cAdvisor, Prometheus), fie nu au cerere în comunitate. Continuă cu Authentik **Proxy Provider**.

| Serviciu | Comentariu |
|---|---|
| **cAdvisor** | UI fără concept de user; doar proxy auth |
| **Prometheus** | La fel. Pentru API consumers folosește `bearer_token_file` la scraper-uri |
| **Grafana Alloy** | UI debug; doar proxy auth |
| **RedisInsight** | Suportă `oauth2-proxy` extern, dar nu OIDC nativ. Stay forwardAuth |
| **SeaweedFS UI** | UI public; S3 IAM e separat. Stay forwardAuth |
| **IT-tools / Omni-tools / Traefik whoami** | Unelte stateless |
| **Traefik dashboard** | Niciun OIDC nativ. ForwardAuth e standard |
| **Homepage** | Citește `X-authentik-*` headers și afișează userul logat (poți activa `headers` widget) |

---

## ⚫ Nu pot fi integrate cu Authentik (deocamdată)

| Serviciu | Status |
|---|---|
| **ntfy** | OIDC e feature request deschis ([issue #1596](https://github.com/binwiederhier/ntfy/issues/1596), feb 2026). Folosește în continuare DB internă cu user/parolă |
| **MongoDB / MySQL / Postgres** | Auth nativ propriu — Authentik OIDC nu se aplică la nivel de DB protocol. **Excepție**: poți expune Authentik ca **LDAP outpost** → MySQL/Mongo Enterprise pot face auth LDAP. Pe MongoDB CE 8.x nu e disponibil |
| **Redis** | Auth via `requirepass` / ACL; OIDC nu există în protocolul Redis |
| **Ollama** | API internă fără concept de user |

---

## ✅ Detaliat: POT fi mutate pe Authentik OIDC (7/13)

| # | Serviciu | Login actual | Migrare la Authentik |
|---|---|---|---|
| 1 | **Grafana** | `GF_SECURITY_ADMIN_USER` + parolă | OIDC nativ via `GF_AUTH_GENERIC_OAUTH_*` — **GRATIS** |
| 2 | **pgAdmin4** | `PGADMIN_DEFAULT_EMAIL` + parolă | OAuth2 via `OAUTH2_CONFIG` + `AUTHENTICATION_SOURCES=['oauth2']` |
| 3 | **RabbitMQ** | `RABBITMQ_DEFAULT_USER` + parolă (management UI) | OAuth2 via plugin `rabbitmq_auth_backend_oauth2` |
| 4 | **Open WebUI** | Sign-up form (acum `WEBUI_AUTH=false`) | OIDC nativ via `OAUTH_CLIENT_ID` + `OPENID_PROVIDER_URL` |
| 5 | **Whatsupdocker** | basic auth (`WUD_AUTH_LOCAL_*`) | OIDC nativ via `WUD_AUTH_OIDC_AUTHENTIK_*` |
| 6 | **Mealie** (custom) | Email + parolă | OIDC nativ via `OIDC_AUTH_ENABLED=true` |
| 7 | **n8n** ⚠️ | User management UI | OIDC doar pe **Enterprise license** (plătit). Free: `n8n-oidc` third-party proxy |

---

## ❌ Detaliat: NU pot fi mutate (6/13)

| # | Serviciu | Login propriu | De ce nu poate |
|---|---|---|---|
| 1 | **ntfy** | DB internă (`auth.db`) cu users + tokens | OIDC = feature request deschis ([issue #1596](https://github.com/binwiederhier/ntfy/issues/1596)), neimplementat |
| 2 | **RedisInsight** | First-time user setup local | Nu suportă OIDC nativ; forwardAuth e singura opțiune |
| 3 | **mongo-express** | Basic auth (acum `ME_CONFIG_BASICAUTH=false`) | Suportă DOAR basic auth — folosește forwardAuth + basic auth ca dublu strat |
| 4 | **phpMyAdmin** | Folosește credentialele MySQL direct | Nu e "app login" — e un proxy către DB. ForwardAuth e tot ce poți face |
| 5 | **Mailpit** | Basic auth (opțional via `MP_UI_AUTH_FILE`) | Doar basic auth — forwardAuth e suficient |
| 6 | **Dozzle** | `users.yml` (basic auth nativ) | Nu are OIDC, dar **acceptă identity din header** via `DOZZLE_AUTH_PROVIDER=forward-proxy` → tehnic poți "muta" autorizarea pe Authentik, dar nu e OIDC real |

> Notă: MongoDB, MySQL, Postgres, Redis, Ollama au auth la nivel de protocol (nu UI/HTTP) — nu intră în această categorie. Sunt accesate cu credențiale fixe din aplicații, nu cu login user.

---

## 🔑 Bonus: LDAP Outpost pentru unificare totală

Authentik are un **LDAP Outpost** (`ghcr.io/goauthentik/ldap:2026.5.0`) care expune userii Authentik ca director LDAP pe portul 3389/6636. Asta îți dă:

- **RabbitMQ LDAP plugin** ca alternativă la OAuth2 (mai simplu)
- **pgAdmin LDAP auth** ca alternativă la OAuth2
- **Mongo Enterprise** auth LDAP (nu pe CE)
- **Mealie LDAP** (există suport nativ)
- **Multe app-uri legacy** care nu vorbesc OIDC dar vorbesc LDAP

În stack-ul tău LDAP outpost ar fi util **mai ales pentru RabbitMQ** dacă OAuth2 backend devine prea complex.

---

## 📋 Prioritizare migrare (ordinea reală a câștigului)

**Prioritate 1 (servicii expuse fără auth — RISC ACUM):**
1. ☐ **Grafana** → OIDC (`GF_AUTH_GENERIC_OAUTH_*`) — 30 min
2. ☐ **pgAdmin4** → OAuth2 (`OAUTH2_CONFIG`) — 45 min
3. ☐ **RabbitMQ** → OAuth2 plugin — 1-2h (e mai complex)
4. ☐ **Mealie** → OIDC (`OIDC_AUTH_ENABLED`) — 30 min
5. ☐ **n8n** → forwardAuth + basic-auth fallback (sau Enterprise OIDC) — 20 min

**Prioritate 2 (defense-in-depth, ai deja forwardAuth):**
6. ☐ **Open WebUI** → `WEBUI_AUTH=true` + OIDC (utilizatorii devin "named")
7. ☐ **Dozzle** → `DOZZLE_AUTH_PROVIDER=forward-proxy` (RBAC pe shell access)
8. ☐ **Whatsupdocker** → `WUD_AUTH_OIDC_AUTHENTIK_*` (al 2-lea layer auth)

**Prioritate 3 (nice-to-have):**
9. ☐ Deploy **Authentik LDAP outpost** pentru viitoare aplicații legacy

**Restul (cAdvisor, Prometheus, Grafana Alloy, IT-tools, etc.)** — păstrează forwardAuth, e cea mai bună soluție disponibilă.

---

## 🎯 Recomandare concretă

Dacă faci doar **prioritatea 1**, elimini login-uri din 4 servicii expuse fără auth + le unifici pe SSO:

1. **Grafana** — 30 min
2. **pgAdmin4** — 45 min
3. **RabbitMQ** — 1-2h (plugin OAuth2 necesită config mai mult)
4. **Mealie** — 30 min

Câștig: **un singur user/parolă** în Authentik pentru toate, MFA centralizat, audit log unic, group-based RBAC.

Pentru **n8n** (cel mai sensibil pentru o firmă — automatizări cu API keys) cea mai bună soluție gratuită rămâne forwardAuth + n8n basic auth ca dublu strat.

Pentru **ntfy/RedisInsight/mongo-express/phpMyAdmin/Mailpit/Dozzle** — păstrezi forwardAuth-ul actual; nu există beneficiu real să "muți" ceva.

---

## Surse

- [Authentik Grafana integration](https://integrations.goauthentik.io/monitoring/grafana/)
- [Authentik pgAdmin integration](https://integrations.goauthentik.io/infrastructure/pgadmin/)
- [Authentik RabbitMQ integration](https://integrations.goauthentik.io/infrastructure/rabbitmq/)
- [Authentik WUD integration](https://integrations.goauthentik.io/monitoring/whats-up-docker/)
- [Authentik Mealie integration](https://integrations.goauthentik.io/documentation/mealie/)
- [Authentik Open WebUI integration](https://docs.goauthentik.io/integrations/services/open-webui/)
- [Authentik Proxy Provider docs](https://docs.goauthentik.io/add-secure-apps/providers/proxy/)
- [Authentik LDAP outpost in Docker Compose](https://docs.goauthentik.io/add-secure-apps/outposts/manual-deploy-docker-compose/)
- [Dozzle authentication providers](https://dozzle.dev/guide/authentication)
- [Open WebUI SSO/OAuth/OIDC](https://docs.openwebui.com/features/authentication-access/auth/sso/)
- [n8n OIDC setup (Enterprise)](https://docs.n8n.io/user-management/oidc/setup/)
- [Mealie OIDC docs](https://docs.mealie.io/documentation/getting-started/authentication/oidc/)
- [ntfy OIDC feature request #1596](https://github.com/binwiederhier/ntfy/issues/1596)
