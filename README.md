# Práctica RA2: WordPress con Nginx y PHP-FPM

Este repositorio contiene la configuración para desplegar un stack de WordPress utilizando Nginx, PHP-FPM y MariaDB mediante Docker Compose. Proyecto realizado para el módulo de Implantación de Aplicaciones Web (IAW) del ciclo de 2º ASIR.

## Objetivo del Proyecto
Sustituir el servidor web Apache del RA1 por una arquitectura basada en **Nginx + PHP-FPM**, configurando una base de datos MariaDB con un usuario dedicado y privilegios limitados para mejorar la seguridad y el rendimiento.

## Arquitectura de Contenedores
El stack se compone de tres servicios conectados en la misma red interna de Docker:
- **nginx**: Servidor web que recibe las peticiones en el puerto 8080 y procesa los archivos estáticos.
- **wordpress**: Contenedor con la imagen 7.1-php8.3-fpm que procesa el código PHP de la aplicación.
- **db**: Base de datos MariaDB en su versión 11.

Tanto Nginx como WordPress comparten el volumen wp_data para tener acceso simultáneo a los ficheros del CMS.

## Despliegue
1. Clona este repositorio (rama a2-cms).
2. Crea un archivo .env en la raíz basándote en la estructura de .env.example y define las contraseñas seguras.
3. Levanta el stack en segundo plano:
   \\\ash
   docker compose up -d
   \\\
4. Accede al instalador web desde el navegador en \http://localhost:8080\.
