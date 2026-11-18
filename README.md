# Práctica RA2: Despliegue y Administración de WordPress con Nginx y PHP-FPM

Este repositorio contiene la arquitectura completa para desplegar y administrar **WordPress** utilizando una infraestructura desacoplada de contenedores basada en **Nginx**, **PHP-FPM** y **MariaDB**.

Trabajo correspondiente al **Resultado de Aprendizaje 2 (RA2)** del módulo *Implantación de Aplicaciones Web (IAW)*, 2º ASIR.

---

## 1. Descripción del Proyecto y Arquitectura

El objetivo principal es sustituir el servidor web monolítico Apache (utilizado en RA1) por una arquitectura desacoplada de alto rendimiento y bajo consumo de recursos:
* **`nginx` (imagen `nginx:stable`)**: Actúa como servidor web frontal en el puerto `8080`, sirviendo ficheros estáticos, aplicando directivas de seguridad (ocultación de versión, cabeceras defensivas y denegación de rutas críticas) y redirigiendo las peticiones dinámicas.
* **`wordpress` (imagen `wordpress:7.1-php8.3-fpm`)**: Procesa exclusivamente el código PHP de WordPress a través del protocolo FastCGI (puerto interno 9000). Comparte el volumen `wp_data` con Nginx.
* **`db` (imagen `mariadb:11`)**: Motor de base de datos relacional que almacena tablas, contenidos, configuraciones y usuarios del CMS en el volumen persistente `db_data`.

Ambos servicios web (`nginx` y `wordpress`) comparten el volumen `wp_data` montado en `/var/www/html` para garantizar la coherencia en la lectura y ejecución de ficheros.

---

## 2. Requisitos Previos

* **Docker Engine** y **Docker Compose v2** (o Docker Desktop en Windows con backend WSL2).
* **Git** para la gestión y clonado del repositorio.
* Cliente HTTP en consola (`curl`) o navegador web.

---

## 3. Despliegue Local Paso a Paso desde Cero

Para reproducir este entorno desde cero en cualquier equipo nuevo:

### Paso 1: Clonar el repositorio
```bash
git clone https://github.com/rendechen14/ra2-cms.git
cd ra2-cms
git checkout ra2-cms
```

### Paso 2: Crear el archivo de variables de entorno `.env`
Copia la plantilla `.env.example` para generar tu archivo `.env` local con tus contraseñas seguras:
```bash
cp .env.example .env
```
Edita `.env` y define las variables:
```dotenv
MYSQL_ROOT_PASSWORD=tu_clave_root_segura
MYSQL_DATABASE=wp_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=tu_clave_usuario_segura

WP_DB_NAME=wp_db
WP_DB_USER=wp_user
WP_DB_PASSWORD=tu_clave_usuario_segura
```

### Paso 3: Inicializar la Base de Datos y el Usuario de WordPress
Levanta únicamente el servicio de base de datos en segundo plano:
```bash
docker compose up -d db
```
Accede al cliente interactivo de MariaDB con la clave de root:
```bash
docker compose exec db sh -c 'mariadb -u root -p"$MYSQL_ROOT_PASSWORD"'
```
Ejecuta las sentencias SQL para crear la base de datos y otorgar permisos exclusivos al usuario de WordPress:
```sql
CREATE DATABASE wp_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wp_user'@'%' IDENTIFIED BY 'tu_clave_usuario_segura';
GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_user'@'%';
FLUSH PRIVILEGES;
EXIT;
```

### Paso 4: Levantar el stack completo
Inicia los tres servicios:
```bash
docker compose up -d
```
Comprueba que los tres contenedores estén en estado *Up*:
```bash
docker compose ps
```

### Paso 5: Completar la instalación web de WordPress
1. Abre en tu navegador: [http://localhost:8080](http://localhost:8080)
2. Selecciona el idioma (*Español*).
3. Introduce el título del sitio y define las credenciales del usuario administrador:
   * **Nombre de usuario:** Un identificador seguro (nunca `admin`).
   * **Contraseña:** Clave robusta.
   * **Correo electrónico:** Tu dirección de correo.
4. Tras finalizar la instalación, accede al panel de control en [http://localhost:8080/wp-admin](http://localhost:8080/wp-admin).

---

## 4. Publicación en GitHub Codespaces

Este entorno está preparado para publicarse en la nube sin modificar archivos:
1. En el repositorio de GitHub, entra en la pestaña **Codespaces** de la rama `ra2-cms` y pulsa **Create codespace on ra2-cms**.
2. Una vez abierto el entorno en el navegador:
   ```bash
   cp .env.example .env
   # Configura tus credenciales y crea la base de datos (según Paso 3)
   docker compose up -d
   ```
3. En la pestaña **PORTS**, haz clic derecho sobre el puerto `8080` → **Port Visibility** → **Public**.
4. Copia la dirección pública generada (`https://<nombre-codespace>-8080.app.github.dev`) y accede directamente desde cualquier navegador o dispositivo móvil.
   * El bloque `WORDPRESS_CONFIG_EXTRA` en `docker-compose.yml` detectará automáticamente las cabeceras `X-Forwarded-Host` y `X-Forwarded-Proto`, garantizando que todos los enlaces y estilos se carguen bajo HTTPS sin errores de redirección ni contenido mixto.

---

## 5. Estructura del Repositorio

```text
ra2-cms/
├── .env.example            # Plantilla de variables de entorno sin contraseñas
├── .gitignore              # Protección para no subir .env ni logs sensibles
├── docker-compose.yml      # Definición de servicios (nginx, wordpress, db), redes y volúmenes
├── config/
│   └── uploads.ini         # Ajustes de PHP (upload_max_filesize = 64M, memory_limit = 256M)
├── nginx/
│   └── default.conf        # Configuración comentada de Nginx (fastcgi, seguridad y try_files)
├── docs/
│   ├── personalizacion.md  # Justificación de tema, plugins y estructura de contenidos
│   ├── seguridad.md        # Análisis antes/después y detalle de directivas de endurecimiento
│   └── pruebas.md          # Registro de verificación funcional, rendimiento y publicación
└── README.md               # Guía completa de despliegue y reproducción del proyecto
```

---

## 6. Documentación Técnica

Para consultar los informes detallados elaborados durante las sesiones evaluables:
* [Documento de Personalización del Gestor](docs/personalizacion.md)
* [Documento de Medidas de Seguridad y Endurecimiento](docs/seguridad.md)
* [Documento de Pruebas de Funcionamiento y Rendimiento](docs/pruebas.md)


---

## 7. Copias de Seguridad y Restauración (RA3 · Práctica 2)

El proyecto cuenta con scripts automatizados en la carpeta `scripts/` para garantizar la persistencia y recuperación ante desastres:

### Realizar una copia de seguridad:
Ejecuta el script desde la raíz del repositorio:
```bash
./scripts/backup.sh
```
* Genera dos ficheros comprimidos con marca de tiempo en la carpeta `backups/`:
  - `db_AAAAMMDD-HHMMSS.sql.gz`: Volcado SQL íntegro de la base de datos MariaDB.
  - `wp-content_AAAAMMDD-HHMMSS.tar.gz`: Archivo comprimido con temas, plugins y ficheros multimedia.
* Aplica una política de rotación automática conservando las últimas 7 copias y eliminando las más antiguas.

### Restaurar una copia de seguridad:
1. Para listar todas las copias disponibles:
   ```bash
   ./scripts/restore.sh
   ```
2. Para restaurar una copia específica pasando su identificador temporal:
   ```bash
   ./scripts/restore.sh AAAAMMDD-HHMMSS
   ```
* Solicita confirmación explícita escribiendo `SI` antes de sobrescribir.
* Inyecta el volcado SQL en MariaDB y descomprime `wp-content` reasignando la propiedad al usuario `www-data:www-data`.
