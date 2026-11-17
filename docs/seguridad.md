# Seguridad del gestor

| Comprobación | Antes | Después |
|---|---|---|
| Cabecera Server | `nginx/1.30.x` (expone número de versión) | `nginx` (versión oculta mediante `server_tokens off`) |
| /xmlrpc.php | Accesible (devuelve HTTP 405 / 200) | HTTP 403 Forbidden |
| /wp-config.php | Expuesto a peticiones HTTP directas | HTTP 403 Forbidden |
| PHP en uploads | Vulnerable: ejecuta código PHP (devuelve 2) | HTTP 403 Forbidden (bloqueo por expresión regular) |
| Edición de ficheros desde el panel | Permitida (Editor de temas y plugins accesible) | Desactivada (`DISALLOW_FILE_EDIT` en Docker Compose) |
| Límite de intentos de login | Ilimitado (vulnerable a ataques de fuerza bruta) | Bloqueo temporal activo tras varios intentos fallidos |

## Medidas aplicadas y por qué

1. **Ocultación de cabeceras y versión (`server_tokens off` en `nginx/default.conf`):**
   - *Riesgo mitigado:* Reconocimiento de versiones vulnerables (*footprinting*). Al ocultar la versión exacta de Nginx, un atacante no puede identificar rápidamente vulnerabilidades conocidas (CVE) asociadas a dicha versión.
   - *Cabeceras añadidas:* Se implementan `X-Content-Type-Options: nosniff` (previene ataques de adivinación de tipo MIME) y `X-Frame-Options: SAMEORIGIN` (evita ataques de clickjacking impidiendo el embebido en sitios web externos).

2. **Restricción de rutas críticas en Nginx:**
   - **`/xmlrpc.php`:** Históricamente explotado para ataques de fuerza bruta de credenciales mediante llamadas multicall y ataques DDoS de amplificación por *pingback*.
   - **`/wp-config.php`:** Archivo central que almacena las credenciales de la base de datos y las claves sal de WordPress. Se bloquea cualquier intento de petición HTTP directa devolviendo un 403 Forbidden.
   - **`^/wp-content/uploads/.*\.php$`:** Impide la ejecución remota de código (RCE). En caso de que un atacante consiguiese subir un archivo con extensión `.php` a través de una brecha en la subida de medios, Nginx deniega el acceso y no traslada la petición al intérprete PHP-FPM.

3. **Inhabilitación del editor de archivos web (`DISALLOW_FILE_EDIT`):**
   - Configurado en `WORDPRESS_CONFIG_EXTRA` dentro de `docker-compose.yml`.
   - *Riesgo mitigado:* Desactiva los editores integrados de temas y plugins en el panel de WordPress. Si un atacante lograra obtener credenciales de administrador, no podrá inyectar código malicioso (*web shells*) directamente desde la interfaz web.

4. **Control de accesos y principio de menor privilegio:**
   - El usuario administrador inicial no utiliza el nombre `admin`.
   - Se modifica el alias público («Mostrar públicamente como») para que sea distinto al nombre de usuario de inicio de sesión (`user_login`), dificultando la recolección de usuarios mediante enumeración de autores.
   - Se crea una cuenta con rol `Editor` para la operativa habitual, evitando el uso diario de la cuenta con máximos privilegios administrativos.
   - Se implementa un plugin de limitación de intentos de acceso para mitigar ataques automatizados de fuerza bruta por diccionario sobre `wp-login.php`.
