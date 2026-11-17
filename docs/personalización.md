# Personalización del sitio

**Tema activo:** (Ej: Twenty Twenty-Four, versión X.X)
**Por qué lo elegí:** (Breve razonamiento sobre su diseño, ligereza o adaptabilidad)
**Plugin instalado:** (Ej: Contact Form 7, versión X.X, última actualización reciente, más de 5 millones de instalaciones)
**Por qué lo necesito:** (Para permitir la comunicación directa de los usuarios mediante un formulario seguro)
**Estructura de contenidos:** 
- Páginas: Inicio (portada estática), Sobre el proyecto (con su subpágina Tecnologías) y Contacto.
- Categorías: Novedades y Tutoriales.
- Menú principal configurado con jerarquía de subpáginas.
```[cite: 12, 13]

### 📄 Fichero `docs/seguridad.md` (Sesión 12)
```markdown
# Seguridad del gestor

| Comprobación | Antes | Después |
|---|---|---|
| Cabecera Server | Visible (con versión) | Oculta / Genérica |
| /xmlrpc.php | Accesible (200 OK) | Bloqueado (403 Forbidden) |
| /wp-config.php | Accesible / Expuesto | Bloqueado (403 Forbidden) |
| PHP en uploads | Ejecutable (devuelve resultado) | Bloqueado (403 Forbidden) |
| Edición de ficheros desde el panel | Permitida | Desactivada (DISALLOW_FILE_EDIT) |
| Límite de intentos de login | Sin protección | Protegido con plugin de bloqueo |

## Medidas aplicadas y por qué
1. **Endurecimiento de Nginx:** Se han añadido reglas de denegación explícita para ficheros sensibles y directorios multimedia para evitar la ejecución arbitraria de código malicioso.
2. **Restricción de privilegios y edición:** Se bloqueó la modificación de código fuente desde el panel de administración de WordPress mediante constantes de configuración en el entorno de Docker.
3. **Control de accesos:** Uso de contraseñas robustas, ocultación del usuario administrador predeterminado y limitación de intentos de inicio de sesión.
```[cite: 15, 16, 17]

---

<ElicitationsGroup message="¿Qué comprobación o fichero quieres que revisemos ahora para asegurarnos de que lo tienes todo perfecto?">
  <Elicitation label="Revisar nginx/default.conf" query="¿Cómo debe quedar exactamente el contenido de nginx/default.conf con las medidas de seguridad?"/>
  <Elicitation label="Pasos de Git para entregar" query="¿Qué comandos de Git debo ejecutar para hacer commit y push de esta última fase?"/>
</ElicitationsGroup>