# Nextcloud en Android con Termux

Servidor Nextcloud 24/7 corriendo en un Samsung Galaxy Android con Termux, Apache, MariaDB, Redis, PHP-FPM y Cloudflare Tunnel.

## Arquitectura

```
┌──────────────────────────────────────────────────┐
│                   ANDROID PHONE                    │
│  ┌──────────┐  ┌──────────┐  ┌────────────────┐  │
│  │ Tasker   │  │ Termux   │  │  Termux:Boot   │  │
│  │ (WhatsApp│  │ :Widget  │  │  (auto-arranque)│  │
│  │ trigger) │  │          │  │                │  │
│  └────┬─────┘  └────┬─────┘  └───────┬────────┘  │
│       └──────────────┼───────────────┘           │
│                      ▼                           │
│  ┌──────────────────────────────────────────────┐│
│  │           scripts/start_nextcloud.sh          ││
│  │                                               ││
│  │   Redis :6379  ←→  MariaDB :3306              ││
│  │      ↑                  ↑                     ││
│  │   PHP-FPM :9000  ←→  Apache :8080             ││
│  │      ↑                       ↑                ││
│  │   Nextcloud PHP              │                ││
│  │   (nextcloud_html/)          │                ││
│  └──────────────────────────────┼────────────────┘│
│                                 │                │
│  ┌──────────────────────────────▼────────────────┐│
│  │         Cloudflare Tunnel (trycloudflare)      ││
│  │                         ↓                      ││
│  │         Cloudflare Worker (workers.dev)        ││
│  │                         ↓                      ││
│  │         HTTPS Público (nextcloud.workers.dev)  ││
│  └───────────────────────────────────────────────┘│
└──────────────────────────────────────────────────┘
```

## Especificaciones del servidor

| Componente | Detalle |
|---|---|
| **Dispositivo** | Samsung Galaxy |
| **OS** | Android (Termux proot) |
| **Uptime** | Desde **2023** |
| **Almacenamiento** | 226GB total, 127G usado, 99G libre |
| **RAM** | 5.6GB total, 3.8GB en uso |
| **Swap** | 4.2GB (2.8G usado) |

### Software

| Servicio | Puerto | Versión |
|---|---|---|
| **Apache HTTPD** | 8080 / 8081 | 2.4.66 |
| **MariaDB** | 3306 | 11.8.6 |
| **PHP-FPM** | 9000 | 8.5 |
| **Redis** | 6379 | Última |
| **Cloudflare Tunnel** | dinámico | trycloudflare |
| **Cloudflare Worker** | - | Proxy inverso |
| **Nextcloud** | - | **33.0.3.2** |

### Módulos PHP instalados

`bcmath`, `curl`, `gd`, `gmp`, `igbinary`, `imagick`, `intl`, `mbstring`, `mysql`, `readline`, `redis`, `xml`, `zip`, `apcu`

## Instalación desde cero

### 1. Termux desde F-Droid

```
https://f-droid.org/packages/com.termux/
```

### 2. Paquetes base

```bash
pkg update && pkg upgrade -y
pkg install apache2 mariadb redis php php-fpm \
    php-apcu php-bcmath php-curl php-gd php-gmp \
    php-igbinary php-imagick php-intl php-mbstring \
    php-mysql php-redis php-xml php-zip \
    curl wget git openssh
```

### 3. Configurar MariaDB

```bash
mariadb-install-db
mariadbd --user=root &
mysql -u root
```

```sql
CREATE USER 'ncuser'@'localhost' IDENTIFIED BY 'tu_password';
CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'ncuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 4. Descargar Nextcloud

```bash
cd /data/data/com.termux/files/home
wget https://download.nextcloud.com/server/releases/nextcloud-33.0.3.tar.bz2
tar -xf nextcloud-33.0.3.tar.bz2
mv nextcloud nextcloud_html
```

### 5. Configurar Apache

Crea `/data/data/com.termux/files/usr/etc/apache2/sites-available/nextcloud.conf`:

```apache
<VirtualHost *:8080>
    ServerName localhost
    DocumentRoot /data/data/com.termux/files/home/nextcloud_html

    <Directory /data/data/com.termux/files/home/nextcloud_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:fcgi://127.0.0.1:9000"
    </FilesMatch>

    ErrorLog  /data/data/com.termux/files/home/logs/apache_error.log
    CustomLog /data/data/com.termux/files/home/logs/apache_access.log combined
</VirtualHost>
```

Habilita el sitio:

```bash
ln -s /data/data/com.termux/files/usr/etc/apache2/sites-available/nextcloud.conf \
      /data/data/com.termux/files/usr/etc/apache2/sites-enabled/
```

### 6. Configurar PHP

Ajusta `memory_limit`, `upload_max_filesize`, `post_max_size` en `php.ini` para el servidor.

## Scripts de gestión

| Script | Función |
|---|---|
| `scripts/start_nextcloud.sh` | Inicia todos los servicios (Redis → MariaDB → PHP-FPM → Apache → Cloudflare → Worker → Cron) |
| `scripts/stop_nextcloud.sh` | Detiene todos los servicios en orden inverso |
| `scripts/status_nextcloud.sh` | Muestra estado de todos los servicios |
| `scripts/restart_nextcloud.sh` | Detiene e inicia todo |
| `scripts/backup_nextcloud.sh` | Backup de configuración (scripts, logs, config.php) |
| `scripts/cron_loop.sh` | Loop que ejecuta `cron.php` cada 5 minutos |
| `scripts/start_tunnel.sh` | Inicia solo el túnel Cloudflare |
| `scripts/update_worker.sh` | Actualiza el worker de Cloudflare |
| `scripts/sync_nextcloud.sh` | Sincronización de datos |
| `scripts/install_php_modules.sh` | Instala módulos PHP faltantes |
| `scripts/test_mariadb.sh` | Verifica conexión a MariaDB |
| `scripts/coolwsd_start.sh` | Inicia LibreOffice Online |
| `scripts/coolwsd_stop.sh` | Detiene LibreOffice Online |

### Modo de uso

```bash
# Iniciar servidor
bash ~/scripts/start_nextcloud.sh

# Ver estado
bash ~/scripts/status_nextcloud.sh

# Detener
bash ~/scripts/stop_nextcloud.sh

# Backup
bash ~/scripts/backup_nextcloud.sh backup
```

Los scripts usan un sistema de detección de procesos compatible con Android vía `/proc` (no requieren `pgrep`).

## Auto-arranque (Termux:Boot)

El archivo `boot/start_nextcloud.sh` debe copiarse a `~/.termux/boot/`:

```bash
cp boot/start_nextcloud.sh ~/.termux/boot/
chmod +x ~/.termux/boot/start_nextcloud.sh
```

Esto inicia el servidor automáticamente al encender el teléfono (después de 15s de espera para asegurar que la red esté disponible).

**Importante:** Desactivar la optimización de batería para Termux:
```
Ajustes Android → Apps → Termux → Batería → Sin restricción
```

## Shortcuts (Widgets)

Para control manual desde la pantalla de inicio:

```bash
cp shortcuts/* ~/.shortcuts/
chmod +x ~/.shortcuts/*
```

Luego agregar widgets de **Termux:Widget** en el escritorio.

| Shortcut | Función |
|---|---|
| `Iniciar Nextcloud` | Inicia todos los servicios |
| `Detener Nextcloud` | Detiene todos los servicios |
| `Estado Nextcloud` | Muestra estado |
| `Reiniciar Nextcloud` | Reinicia servicios |

## Automatización con Tasker + WhatsApp

Tasker se usa como interfaz para **iniciar/detener el servidor desde WhatsApp**:

### Configuración

1. **Tasker → Profiles → + → Event → Notification**
   - App: WhatsApp
   - Contiene texto: `/start` o `/stop` o `/status`
2. **Task** → Plugin → **Termux:Tasker**
   - Command: `bash /data/data/com.termux/files/home/.shortcuts/Iniciar Nextcloud`
   - (o el shortcut correspondiente)

### Comandos disponibles desde WhatsApp

| Mensaje | Acción |
|---|---|
| `/start` | Inicia Nextcloud |
| `/stop` | Detiene Nextcloud |
| `/status` | Muestra estado |

### Alternativa sin WhatsApp (perfiles por batería)

Ver el proyecto complementario: **[nextcloud-android-tasker](https://github.com/sebastian09781/nextcloud-android-tasker)** que controla un enchufe Tuya para mantener la batería entre 30-80%.

## Cloudflare Worker

El worker actúa como proxy inverso para proporcionar HTTPS y un dominio fijo:

```
https://nextcloud.sebastiancloud.workers.dev
↓ (proxy)
https://RANDOM.trycloudflare.com
↓ (tunnel)
http://127.0.0.1:8080
↓ (Apache)
Nextcloud PHP
```

Se actualiza automáticamente en cada inicio desde `start_nextcloud.sh`.

## Configuración de la base de datos

MariaDB optimizada para Nextcloud en `~/.my.cnf`:

```ini
[mysqld]
innodb_buffer_pool_size        = 256M
innodb_log_file_size           = 16M
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table          = 1
max_connections                = 15
tmp_table_size                 = 16M
max_heap_table_size            = 16M
thread_cache_size              = 4
key_buffer_size                = 8M
query_cache_type               = 0
character-set-server           = utf8mb4
collation-server               = utf8mb4_general_ci
```

## Backup

Crea backups con:

```bash
# Backup manual
bash ~/scripts/backup_nextcloud.sh backup

# Backup con nombre personalizado
bash ~/scripts/backup_nextcloud.sh backup antes_de_actualizar

# Listar backups
bash ~/scripts/backup_nextcloud.sh list

# Restaurar
bash ~/scripts/backup_nextcloud.sh restore <nombre>
```

Los backups incluyen: scripts, variables de entorno, logs y config.php.

## Estructura del proyecto

```
nextcloud-termux/
├── README.md
├── scripts/           # Scripts de gestión (ejemplos)
├── boot/              # Auto-arranque Termux:Boot
├── shortcuts/         # Widgets y Tasker shortcuts
└── config/            # Ejemplos de configuraciones
```

## Repositorio complementario

Para mantener el servidor 24/7 sin degradar la batería, usa el control automático de cargador:

👉 **[nextcloud-android-tasker](https://github.com/sebastian09781/nextcloud-android-tasker)**

Controla un enchufe inteligente Tuya para encender el cargador al 30% y apagarlo al 80%.

## Licencia

MIT
