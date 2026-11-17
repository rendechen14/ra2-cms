# Pruebas de funcionamiento y rendimiento

| Prueba | Resultado | ¿Correcto? |
|---|---|---|
| Servicios en marcha | `docker compose ps` muestra los 3 contenedores (nginx, wordpress, db) en estado Up | Sí |
| Sitio y panel | Portada `/` carga con estilos del tema y acceso funcional en `/wp-admin` | Sí |
| Subida de ficheros | Imagen de varios MB subida a la biblioteca de medios sin errores (límite 64 MB) | Sí |
| Enlaces permanentes | Carga correcta de una entrada individual por su URL amigable sin error 404 | Sí |
| Persistencia (down/up) | Contenido, entradas y base de datos intactos tras `docker compose down` y `docker compose up -d` | Sí |
| Seguridad (403) | Petición a `/xmlrpc.php` responde HTTP/1.1 403 Forbidden | Sí |

## Rendimiento

- **Tiempos de respuesta en el aula (5 medidas):**  
  0.051642s, 0.046208s, 0.046739s, 0.045961s, 0.047342s

- **Memoria por contenedor (docker stats):**  
  - MariaDB 11 (`db`): 122.4 MiB / 7.435 GiB (1.61% MEM, 0.01% CPU)
  - WordPress PHP-FPM (`wordpress`): 75.8 MiB / 7.435 GiB (1.00% MEM, 0.01% CPU)
  - Nginx (`nginx`): 16.8 MiB / 7.435 GiB (0.22% MEM, 0.00% CPU)

- **Interpretación:**  
  La primera petición (0.0516s) resulta ligeramente más lenta que las siguientes (~0.046s) debido al proceso de arranque en frío (*cold start*), durante el cual se establecen los sockets de conexión FastCGI entre Nginx y PHP-FPM, la conexión con MariaDB y se cargan las estructuras de datos en el búfer relacional (*InnoDB buffer pool*). A partir de la segunda petición, los tiempos se reducen y estabilizan gracias a la caché de código precompilado de PHP (*OPcache*) y los búferes internos de la base de datos.  
  En cuanto al consumo de memoria, MariaDB y WordPress concentran más del 90% del uso global al alojar el motor relacional y el intérprete PHP, mientras que Nginx mantiene un uso mínimo (~17 MiB) al operar como un servidor web asíncrono y liviano orientado a eventos.

## Publicación

- **Dirección desde la que accedió mi compañero/a:**  
  `http://192.168.1.149:8080`

- **Dirección pública en Codespaces (paso 4):**  
  `https://ideal-computing-machine-4jp7r9rg4grr2j76p-8080.app.github.dev/`

- **Tiempos desde Codespaces y comparación con el aula:**  
  - Medidas en Codespaces: 0.989323s, 0.273032s, 0.291696s, 0.291794s, 0.313319s  
  - Comparación técnica:  
    1. *Carga del servidor:* El tiempo de cómputo en la CPU virtual de Codespaces es comparable al entorno local. La primera petición (0.989s) experimenta la inicialización de PHP y de la base de datos, estabilizándose a continuación en torno a 0.29s.  
    2. *Carga de la red:* Prácticamente toda la diferencia de latencia entre el aula (~0.046s) y Codespaces (~0.29s) corresponde a la red de área amplia (WAN): la resolución DNS pública de `*.app.github.dev`, la negociación criptográfica TLS/HTTPS y el tránsito por el proxy inverso perimetral de GitHub.
