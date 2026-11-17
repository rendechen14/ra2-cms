# Personalización del sitio

- **Tema activo:** Twenty Twenty-Four (versión oficial moderna basada en bloques completos / FSE)
- **Por qué lo elegí:** Es el tema oficial más moderno y avanzado de WordPress, con soporte completo de edición del sitio (Full Site Editing), tipografía de alta legibilidad, bloques prediseñados profesionales y un rendimiento optimizado sin dependencias pesadas.
- **Plugin instalado:** Contact Form 7 (versión 6.0+, con más de 5 millones de instalaciones activas, actualizado recientemente y compatible con la versión de WordPress instalada)
- **Por qué lo necesito:** Es una herramienta fundamental para permitir que los usuarios y visitantes del sitio puedan enviar mensajes y consultas directamente a través de la página «Contacto», integrando validación de campos sin comprometer la seguridad del sitio.
- **Estructura de contenidos:**
  - **Páginas:**
    - «Inicio»: Portada principal del sitio configurada como página de inicio estática (a través de *Ajustes → Lectura*), con diseño moderno en bloques, sección de presentación (hero), botones de acción y tarjetas de especialización técnica.
    - «Sobre el proyecto»: Página institucional que describe el propósito y las competencias del ciclo formativo ASIR (Administración de Sistemas Informáticos en Red).
    - «Tecnologías»: Subpágina dependiente (página hija con página superior: «Sobre el proyecto», URL `/sobre-el-proyecto/tecnologias/`), donde se detalla el stack técnico implementado (Nginx, PHP-FPM 8.3, MariaDB 11 y Docker Compose).
    - «Contacto»: Página de comunicación directa con formulario, horarios de tutoría y datos institucionales del centro educativo.
  - **Categorías de entradas:**
    - *Novedades*: Para anuncios, lanzamientos y comunicaciones del portal.
    - *Tutoriales*: Para guías técnicas, manuales de administración y procedimientos de despliegue.
  - **Entradas:** 3 entradas técnicas publicadas y distribuidas entre las categorías:
    1. *Despliegue del nuevo stack web* (Novedades)
    2. *Optimización de rendimiento con Nginx y PHP-FPM* (Tutoriales)
    3. *Endurecimiento y seguridad en CMS* (Tutoriales)
  - **Menú de navegación principal:** Configurado con la jerarquía exacta requerida:
    - Inicio (`/`)
    - Sobre el proyecto (`/sobre-el-proyecto/`)
      - Tecnologías (subelemento desplegable: `/sobre-el-proyecto/tecnologias/`)
    - Contacto (`/contacto/`)
