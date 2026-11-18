# INFORME DE PRÁCTICA RA3: Usuarios, Perfiles y Módulos en WordPress

**Módulo:** Implantación de Aplicaciones Web (IAW) · 2º ASIR  
**Alumno:** Rende Chen Xu  
**Centro:** IES Lluís Simarro  
**Rama Git:** `ra3-admin`  

---

## 1. Sección 1: Usuarios, Roles y Capacidades

### 1.1. Tabla de roles y permisos observados

| Rol | Capacidades clave que posee | Qué puede hacer | Qué NO puede hacer |
|---|---|---|---|
| **Administrador** (`iaw_admin`) | `manage_options`, `install_plugins`, `edit_theme_options`, `promote_users`, etc. | Acceso absoluto a todos los ajustes del sistema, temas, módulos, creación de usuarios y gestión integral. | — *(Posee todos los privilegios del CMS)* |
| **Editor** (`coord.web`) | `publish_posts`, `edit_others_posts`, `delete_others_posts`, `moderate_comments`, `manage_categories` | Publicar y editar entradas y páginas propias o de otros autores, moderar comentarios y gestionar taxonomías. | Modificar ajustes del sitio, instalar o activar plugins, cambiar temas o gestionar usuarios. |
| **Autor** (`profe.redes`) | `publish_posts`, `edit_posts`, `delete_posts`, `upload_files` | Redactar, subir imágenes y multimedia, y publicar o eliminar sus propias entradas. | Editar o borrar contenido creado por otros usuarios, crear páginas fijas o tocar configuraciones. |
| **Colaborador** (`alumna.fct`) | `edit_posts`, `delete_posts` *(solo en borradores propios)*, `read` | Redactar y editar sus propios borradores y enviarlos a revisión editorial. | Publicar directamente (`publish_posts`), subir archivos multimedia (`upload_files`) o ver contenido de otros. |
| **Suscriptor** (`familia.garcia`) | `read` | Iniciar sesión, consultar contenidos privados y modificar los datos de su propio perfil de usuario. | Crear cualquier tipo de contenido, subir archivos o acceder al panel administrativo principal. |
| **Revisor** (`revisor.fp`) *(Rol a medida)* | Clonado de `Editor` sin capacidades de borrado (`delete_*`) ni `manage_categories` | Revisar y publicar borradores y entradas de otros autores para garantizar la calidad editorial. | Borrar ninguna entrada ni página (propia o ajena), enviar a la papelera o modificar categorías. |

---

### 1.2. Capacidades críticas analizadas

* **¿Qué capacidad permite publicar contenidos?**  
  La capacidad **`publish_posts`** (para las entradas del blog) y **`publish_pages`** (para las páginas estáticas). Si un usuario carece de esta capacidad (como el rol Colaborador), la interfaz gráfica muestra únicamente el botón *«Enviar para revisión»* en lugar de *«Publicar»*.
* **¿Qué capacidad permite subir ficheros multimedia?**  
  La capacidad **`upload_files`**. Los roles Autor, Editor y Administrador la poseen; mientras que el rol Colaborador la tiene revocada, impidiéndole subir imágenes o documentos a `/wp-content/uploads/`.

---

### 1.3. Comprobaciones prácticas de comportamiento entre perfiles

1. **`alumna.fct` (Colaboradora):** Redactó la entrada *«Mi primera semana en prácticas»*. El editor no ofreció la opción de publicar directamente ni permitió subir archivos adjuntos, quedando en estado *Pendiente de revisión*.
2. **`coord.web` (Editora):** Accedió a la sección *Entradas → Pendientes*, revisó el texto redactado por la alumna y lo publicó oficialmente. En su barra lateral izquierda no figuran los menús *Plugins*, *Apariencia* ni *Ajustes*.
3. **`profe.redes` (Autor):** Publicó su propia entrada técnica sobre redes locales. Al consultar la lista de entradas, no tiene permisos de edición ni borrado sobre la entrada de la alumna.
4. **`familia.garcia` (Suscriptora):** Al iniciar sesión en `/wp-admin`, es redirigida a la pantalla reducida de gestión de su perfil personal.
5. **`revisor.fp` (Rol personalizado Revisor):** Puede acceder a los borradores ajenos y aprobar su publicación, pero no dispone de la acción *Papelera / Mover a la papelera*, garantizando la inmutabilidad de los contenidos existentes.

---

### 1.4. Endurecimiento de la directiva de registro

* **`users_can_register` = `0`:** El registro público de usuarios permanece desactivado. Solo el administrador puede dar de alta cuentas.
* **`default_role` = `subscriber`:** En caso de que se habilitase el autoregistro temporalmente, los nuevos usuarios entrarían siempre con los mínimos privilegios de lectura, mitigando vectores de escalada de privilegios.

---

## 2. Sección 2: Módulos (Plugins) y Justificación Técnica

### 2.1. Requisito R1: Formulario de contacto con persistencia en base de datos
* **Candidatos comparados:** `Contact Form 7 + Flamingo` frente a `WPForms Lite`.
* **Módulo elegido:** **Contact Form 7** (v6.2.5) + **Flamingo** (v2.6.4).
* **Criterios de elección y justificación técnica:**  
  1. *Desacoplamiento y arquitectura de contenedores:* En un entorno Dockerizado sin servidor de correo local (MTA/Postfix), el uso de la directiva `skip_mail: on` en Contact Form 7 evita que el CMS devuelva errores de envío de correo electrónico.
  2. *Persistencia relacional:* Flamingo intercepta y almacena automáticamente todas las entradas y metadatos en las tablas relacionales de la base de datos MariaDB, permitiendo auditar y exportar los mensajes desde el panel administrativo (*Flamingo → Mensajes entrantes*).
  3. *Personalización avanzada:* Se añadió con éxito el campo selectivo `ciclo` (`[select ciclo "ASIR" "DAW" "SMR"]`), adaptado a las necesidades de la comunidad educativa.

### 2.2. Requisito R2: Aviso y consentimiento de Cookies (LSSI-CE y RGPD)
* **Candidatos comparados:** `Cookie Notice & Compliance for GDPR / CCPA` frente a `Complianz`.
* **Módulo elegido:** **Cookie Notice** (v3.1.19).
* **Criterios de elección y justificación técnica:**  
  1. *Rendimiento y ligereza:* No añade tablas redundantes ni sobrecarga de scripts en el *frontend*, manteniendo tiempos de respuesta inferiores a 0.05s.
  2. *Cumplimiento normativo:* Permite configurar de forma simétrica los botones de *Aceptar* y *Rechazar* con idéntico peso visual, almacenando la decisión en una cookie técnica local para que no vuelva a desplegarse en sesiones recurrentes.

### 2.3. Requisito R3: Auditoría y Registro de Actividad
* **Candidatos comparados:** `Simple History` frente a `WP Activity Log`.
* **Módulo elegido:** **Simple History** (v5.36.0).
* **Criterios de elección y justificación técnica:**  
  1. *Trazabilidad de seguridad:* Registra eventos críticos como intentos fallidos y exitosos de inicio de sesión, cambios de perfil, activación o desactivación de extensiones y publicación de contenidos.
  2. *Preparación para auditoría:* Permite centralizar la traza de actividad del equipo docente y de administración para el análisis y explotación de registros previsto en las prácticas posteriores.

### 2.4. Minimización de la Superficie de Ataque
* Siguiendo el principio de menor exposición, se procedió a la desactivación y eliminación definitiva de los plugins preinstalados **`akismet`** y **`hello`** (Hello Dolly). Al eliminar el código inactivo del volumen `wp_data`, se anulan potenciales vectores de explotación por vulnerabilidades de software no mantenido.


---

## 3. Sección 3: Copias de Seguridad y Prueba de Restauración (Práctica 2)

### 3.1. Prueba de Desastre Controlado y Recuperación
1. **Generación de copia de seguridad previa:**  
   Se ejecutó el script `./scripts/backup.sh`, el cual comprobó el estado de los servicios `db` y `wordpress`, realizó el volcado comprimido de la base de datos MariaDB (`db_AAAAMMDD-HHMMSS.sql.gz`) y el empaquetado del directorio multimedia y plugins (`wp-content_AAAAMMDD-HHMMSS.tar.gz`) dentro del directorio local `backups/`.
2. **Inducción del desastre controlado:**  
   * Se eliminó de manera irreversible una entrada del blog saltándose la papelera mediante el comando:
     ```bash
     ./wp post delete <ID> --force
     ```
   * Se eliminó el módulo de almacenamiento de mensajes:
     ```bash
     ./wp plugin delete flamingo
     ```
   * Se verificó visual y mediante `./wp post list` y `./wp plugin list` que los elementos habían desaparecido por completo del sistema.
3. **Ejecución del script de restauración:**  
   * Se consultaron las copias disponibles ejecutando `./scripts/restore.sh`.
   * Se procedió a la restauración pasando la marca temporal de la copia y escribiendo la confirmación explícita `SI`:
     ```bash
     ./scripts/restore.sh AAAAMMDD-HHMMSS
     ```
4. **Verificación tras la restauración:**  
   * Tras la importación del volcado SQL y la descompresión de `wp-content`, la entrada eliminada reapareció inmediatamente en `./wp post list`.
   * El plugin `flamingo` volvió a figurar en estado activo en `./wp plugin list` junto con todos los mensajes entrantes registrados previamente, acreditando el éxito total de la restauración.
