## Docker Tech Stack (Local Dev)

Kumpulan layanan Docker Compose untuk kebutuhan pengembangan lokal: database, cache, message broker, dan tool pendukung (UI/monitoring). Beberapa layanan tambahan disertakan sebagai komentar sehingga bisa diaktifkan sesuai kebutuhan.

### Komponen Aktif
- **MySQL 8.0**: port `3306`, kredensial default untuk pengembangan
  - ROOT: `root` / `rootpassword`
  - DB: `app_db`, USER: `app_user`, PASS: `app_password`
- **phpMyAdmin**: UI MySQL di `http://localhost:8080`
- **Zookeeper**: port internal `2181` (dibutuhkan Kafka)
- **Kafka (Confluent 7.3.2)**:
  - Listener eksternal: `localhost:9092`
  - Listener internal antar-kontainer: `kafka:29092`
- **Kafka UI**: `http://localhost:9080` (cluster `local` terhubung ke `kafka:29092`)
- **Redis 7**: port `6379`

### Komponen Opsional (dikomentari di compose)
- **PostgreSQL**, **MongoDB**, **RabbitMQ**, **Redis Cluster (6 node)**, **LocalTunnel**, **Go App**. Aktifkan dengan menghapus komentar pada blok layanan terkait bila diperlukan.

---

### Prasyarat
- Docker Desktop / Docker Engine + Docker Compose v2
- Make (opsional, untuk menjalankan target di `makefile`)

### Cara Cepat Menjalankan
1) Jalankan seluruh layanan:

```bash
docker compose up -d
# atau
make up
```

2) Akses cepat layanan:
- **MySQL**: `localhost:3306`
- **phpMyAdmin**: `http://localhost:8080` (host: `mysql`, user: `app_user`, pass: `app_password`)
- **Kafka** (client lokal): `localhost:9092`
- **Kafka UI**: `http://localhost:9080`
- **Redis**: `localhost:6379`

3) Hentikan layanan:

```bash
docker compose down
# atau
make down
```

4) Reset total (hapus kontainer + data):

```bash
docker compose down -v
rm -rf ./docker_volumes
```

Catatan: Docker akan membuat folder bind mount jika belum ada. Anda juga dapat menyiapkan struktur folder secara manual (lihat bagian Volumes).

---

### Volumes & Persistensi Data
- Named volume:
  - `mysql_data` → data MySQL persisten di Docker volume
- Bind mounts (di dalam repo):
  - Zookeeper: `./docker_volumes/zookeeper/data`, `./docker_volumes/zookeeper/log`
  - Kafka: `./docker_volumes/kafka`
  - Redis: `./docker_volumes/data/redis`

Struktur minimal yang disarankan (jika ingin menyiapkan manual):

```bash
mkdir -p ./docker_volumes/zookeeper/data \
         ./docker_volumes/zookeeper/log \
         ./docker_volumes/kafka \
         ./docker_volumes/data/redis
```

Perhatian: target `init_docker_volumes` pada `makefile` membuat beberapa direktori contoh, namun struktur Redis pada `docker-compose.yml` menggunakan `./docker_volumes/data/redis`. Sesuaikan bila Anda memilih menggunakan `make init_docker_volumes`.

---

### Perintah Makefile
- `make up`: menjalankan semua layanan (`docker compose up -d`)
- `make down`: mematikan semua layanan (`docker compose down`)
- `make init_docker_volumes`: membuat struktur direktori contoh untuk beberapa layanan

---

### Konfigurasi Penting
- **MySQL**:
  - Env: `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `TZ=Asia/Jakarta`
- **Kafka**:
  - `KAFKA_ADVERTISED_LISTENERS`: `PLAINTEXT://localhost:9092` (untuk klien di host) dan `PLAINTEXT_INTERNAL://kafka:29092` (untuk antar-kontainer)
  - `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP`: kedua listener menggunakan `PLAINTEXT`
- **Kafka UI**:
  - Sudah disiapkan cluster `local` (bootstrap: `kafka:29092`)
  - Ada contoh entri untuk `dev` dan `uat` (alamat eksternal). Hapus jika tidak diperlukan.

---

### Troubleshooting
- **Port sudah digunakan**: ubah port host di `docker-compose.yml` atau hentikan proses yang bentrok.
- **Kafka client tidak bisa connect**:
  - Gunakan `bootstrap.servers=localhost:9092` dari host.
  - Dari dalam kontainer lain di network yang sama, gunakan `kafka:29092`.
  - Periksa firewall/VPN yang memblok koneksi.
- **Kafka UI tidak menampilkan data**:
  - Pastikan Kafka berjalan dan `KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS` mengarah ke `kafka:29092`.
  - Hapus entri `dev/uat` jika tidak relevan untuk lingkungan lokal.
- **Reset data**: `docker compose down -v` lalu hapus folder `./docker_volumes` jika perlu.

---

### Keamanan
Semua kredensial di sini hanya untuk pengembangan lokal. Jangan gunakan konfigurasi ini untuk produksi tanpa peninjauan keamanan.

---

### Lisensi
Tidak ditentukan. Tambahkan berkas lisensi bila diperlukan.

