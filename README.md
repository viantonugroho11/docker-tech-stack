## Docker Tech Stack (Local Dev)

A curated Docker Compose stack for local development: databases, cache, message broker, and supporting tools (UI/monitoring). Several optional services are included as commented blocks so you can enable them as needed.

### Active Components
- **MySQL 8.0**: port `3306`, development credentials
  - ROOT: `root` / `rootpassword`
  - DB: `app_db`, USER: `app_user`, PASS: `app_password`
- **phpMyAdmin**: MySQL UI at `http://localhost:8080`
- **Zookeeper**: internal port `2181` (required by Kafka)
- **Kafka (Confluent 7.3.2)**:
  - External listener: `localhost:9092`
  - Internal inter-container listener: `kafka:29092`
- **Kafka UI**: `http://localhost:9080` (the `local` cluster points to `kafka:29092`)
- **Redis 7**: port `6379`

### Optional Components (commented in compose)
- **PostgreSQL**, **MongoDB**, **RabbitMQ**, **Redis Cluster (6 nodes)**, **LocalTunnel**, **Go App**. Enable by uncommenting the respective service blocks when needed.

---

### Prerequisites
- Docker Desktop / Docker Engine + Docker Compose (v2 recommended; v1 works with `docker-compose`)
- Make (optional, to use `make` targets)

### Quick Start
1) Start all services:

```bash
# Docker Compose v2
docker compose up -d
# or Docker Compose v1
docker-compose up -d
# or via Make
make up
```

2) Service endpoints:
- **MySQL**: `localhost:3306`
- **phpMyAdmin**: `http://localhost:8080` (host: `mysql`, user: `app_user`, pass: `app_password`)
- **Kafka** (from host): `localhost:9092`
- **Kafka UI**: `http://localhost:9080`
- **Redis**: `localhost:6379`

3) Stop services:

```bash
# Docker Compose v2
docker compose down
# or Docker Compose v1
docker-compose down
# or via Make
make down
```

4) Full reset (remove containers + data):

```bash
docker compose down -v || docker-compose down -v
rm -rf ./docker_volumes
```

Note: Docker will create bind mount folders if they don’t exist. You can also prepare the folder structure manually (see Volumes).

---

### Volumes & Data Persistence
- Named volume:
  - `mysql_data` → persistent MySQL data in a Docker-managed volume
- Bind mounts (inside the repo):
  - Zookeeper: `./docker_volumes/zookeeper/data`, `./docker_volumes/zookeeper/log`
  - Kafka: `./docker_volumes/kafka`
  - Redis: `./docker_volumes/data/redis`

Recommended minimal structure (if creating manually):

```bash
mkdir -p ./docker_volumes/zookeeper/data \
         ./docker_volumes/zookeeper/log \
         ./docker_volumes/kafka \
         ./docker_volumes/data/redis
```

Heads-up: the `init_docker_volumes` target in the `makefile` creates sample directories, but Redis in `docker-compose.yml` uses `./docker_volumes/data/redis`. Adjust accordingly if you choose to run `make init_docker_volumes`.

---

### Makefile Targets
- `make up`: start all services (`docker compose up -d`)
- `make down`: stop all services (`docker compose down`)
- `make init_docker_volumes`: create sample directories for several services

---

### Key Configuration
- **MySQL**:
  - Env: `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `TZ=Asia/Jakarta`
- **Kafka**:
  - `KAFKA_ADVERTISED_LISTENERS`: `PLAINTEXT://localhost:9092` (for host clients) and `PLAINTEXT_INTERNAL://kafka:29092` (for inter-container)
  - `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP`: both listeners use `PLAINTEXT`
- **Kafka UI**:
  - Preconfigured `local` cluster (bootstrap: `kafka:29092`)
  - Example entries for `dev` and `uat` (external addresses). Remove if not needed.

---

### Troubleshooting
- **Port already in use**: change host ports in `docker-compose.yml` or stop the conflicting process.
- **Kafka client cannot connect**:
  - From host use `bootstrap.servers=localhost:9092`.
  - From another container on the same network use `kafka:29092`.
  - Check firewall/VPN that may block connections.
- **Kafka UI shows no data**:
  - Ensure Kafka is running and `KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS` points to `kafka:29092`.
  - Remove `dev/uat` entries if not relevant locally.
- **Reset data**: `docker compose down -v` then delete `./docker_volumes` if necessary.

---

### Security
All credentials here are for local development only. Do not use this configuration for production without a security review.

---

### License
Not specified. Add a license file if needed.

