# Pruebas de funcionamiento y rendimiento

| Prueba | Resultado | ¿Correcto? |
|---|---|---|
| Servicios en marcha | docker compose ps muestra los 3 contenedores (
ginx, wordpress, db) en estado Up | Sí |
| Sitio y panel | Portada / carga con estilos del tema y acceso funcional en /wp-admin | Sí |
| Subida de ficheros | Imagen de varios MB subida a la biblioteca de medios sin errores (límite 64 MB) | Sí |
| Enlaces permanentes | Carga correcta de una entrada individual por su URL amigable sin error 404 | Sí |
| Persistencia (down/up) | Contenido, entradas y base de datos intactos tras docker compose down y up -d | Sí |
| Seguridad (403) | Petición a /xmlrpc.php responde HTTP/1.1 403 Forbidden | Sí |

## Rendimiento

- **Tiempos de respuesta en el aula (5 medidas):**  
  0.051642s, 0.046208s, 0.046739s, 0.045961s, 0.047342s

- **Memoria por contenedor (docker stats):**  
  - wordpress-db-1 (MariaDB 11): 122.4 MiB / 7.435 GiB (1.61% MEM, 0.01% CPU)
  - wordpress-wordpress-1 (PHP 8.3 FPM): 75.8 MiB / 7.435 GiB (1.00% MEM, 0.01% CPU)
  - wordpress-nginx-1 (Nginx stable): 16.8 MiB / 7.435 GiB (0.22% MEM, 0.00% CPU)

- **Interpretación:**  
  La primera petición (0.0516s) es ligeramente más lenta que las cuatro siguientes (~0.046s) debido al «arranque en frío» (*cold start*), donde se establecen los hilos de conexión entre Nginx, PHP-FPM y MariaDB, y se cargan las estructuras en memoria (*InnoDB buffer pool*). A partir de la segunda petición, la latencia se reduce y estabiliza gracias a la caché de código precompilado de PHP (*OPcache*) y los búferes de la base de datos[cite: 12].  
  En cuanto al consumo de memoria, MariaDB y WordPress concentran más del 90% del uso global al alojar el motor relacional y el intérprete dinámico de PHP, mientras que Nginx mantiene un uso mínimo (16.8 MiB) al operar como un proxy inverso ligero basado en eventos asíncronos[cite: 12].

## Publicación

- **Dirección desde la que accedió mi compañero/a:**  
  http://192.168.1.149:8080

- **Dirección pública en Codespaces (paso 4):**  
  https://ideal-computing-machine-4jp7r9rg4grr2j76p-8080.app.github.dev/

- **Tiempos desde Codespaces y comparación con el aula:**  
  - Medidas en Codespaces: 0.989323s, 0.273032s, 0.291696s, 0.291794s, 0.313319s  
  - Comparación técnica:  
    1. *Carga del servidor:* El tiempo de procesamiento interno en la CPU virtual de Codespaces es similar al local. La primera petición (0.989s) experimenta la inicialización de PHP y de la base de datos en frío, estabilizándose después en torno a 0.29s[cite: 14].  
    2. *Carga de la red:* Prácticamente toda la diferencia de latencia entre el aula (~0.046s) y Codespaces (~0.29s) corresponde a la red externa WAN: la resolución DNS pública del dominio *.app.github.dev, el intercambio criptográfico TLS/HTTPS y el tráfico a través del proxy inverso perimetral de GitHub[cite: 12, 14].
