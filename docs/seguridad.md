# Seguridad del gestor

| Comprobación | Antes | Después |
|---|---|---|
| Cabecera Server | nginx/1.30.5 (expone versión) | nginx (versión oculta) |
| /xmlrpc.php | Responde (HTTP 405 Method Not Allowed) | HTTP 403 Forbidden |
| /wp-config.php | Expuesto / Sin bloqueo explícito | HTTP 403 Forbidden |
| PHP en uploads | Vulnerable: ejecuta código PHP (devuelve 2) | HTTP 403 Forbidden |
| Edición de ficheros desde el panel | Disponible en Apariencia y Plugins | Desactivada (DISALLOW_FILE_EDIT) |
| Límite de intentos de login | Sin límite (vulnerable a fuerza bruta) | Bloqueo temporal activo tras varios intentos fallidos |

## Medidas aplicadas y por qué

- **Ocultación de cabeceras y versión (nginx/default.conf):** Se añade server_tokens off para mitigar el reconocimiento de vulnerabilidades específicas de la versión de Nginx (footprinting), y se agregan cabeceras de protección (X-Content-Type-Options: nosniff y X-Frame-Options: SAMEORIGIN) para mitigar ataques de MIME-sniffing y clickjacking.
- **Restricción de rutas críticas en Nginx:** Se aplica la directiva deny all sobre xmlrpc.php (vector habitual de fuerza bruta y ataques DDoS de amplificación), sobre wp-config.php (protección de credenciales y claves de seguridad) y sobre cualquier script .php dentro de /wp-content/uploads/ para impedir la ejecución remota de código (RCE) en caso de subida de archivos maliciosos.
- **Bloqueo del editor de código (docker-compose.yml):** Mediante la constante DISALLOW_FILE_EDIT, se inhabilita el editor web integrado en WordPress, evitando que un atacante con acceso a la interfaz administrativa pueda modificar temas o plugins para inyectar web shells.
- **Segregación de roles y mitigación de fuerza bruta:** Se establece un usuario con rol Editor para las tareas cotidianas bajo el principio de menor privilegio, se cambia el alias público del administrador y se activa un plugin de control de intentos para frenar ataques automatizados por diccionario contra wp-login.php.
