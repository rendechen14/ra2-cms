#!/usr/bin/env bash
# =====================================================================
# restore.sh — Restauración de copia de seguridad de WordPress (RA3 · práctica 2)
#
# Uso:
#   ./scripts/restore.sh                    -> lista las copias disponibles
#   ./scripts/restore.sh AAAAMMDD-HHMMSS   -> restaura la copia indicada
# =====================================================================
set -euo pipefail

cd "$(dirname "$0")/.."

DESTINO="backups"

if [ $# -eq 0 ]; then
  echo "Copias disponibles en $DESTINO:"
  if ls "$DESTINO"/db_*.sql.gz 1>/dev/null 2>&1; then
    ls -1 "$DESTINO"/db_*.sql.gz | sed -E 's/.*db_([0-9]{8}-[0-9]{6})\.sql\.gz/\1/'
  else
    echo "No hay copias disponibles."
  fi
  echo ""
  echo "Uso: $0 <timestamp>"
  echo "Ejemplo: $0 20261118-173000"
  exit 0
fi

FECHA="$1"
F_DB="$DESTINO/db_$FECHA.sql.gz"
F_WP="$DESTINO/wp-content_$FECHA.tar.gz"

if [ ! -f "$F_DB" ] || [ ! -f "$F_WP" ]; then
  echo "ERROR: no se encuentran ambos ficheros de copia para la fecha $FECHA" >&2
  echo "Buscados: $F_DB y $F_WP" >&2
  exit 1
fi

echo "ATENCIÓN: Esta acción sobrescribirá la base de datos y la carpeta wp-content."
read -r -p "¿Estás seguro de que deseas continuar? Escribe SI para confirmar: " CONFIRMAR
if [ "$CONFIRMAR" != "SI" ]; then
  echo "Restauración cancelada."
  exit 0
fi

# 0. Comprobar que los servicios necesarios están en marcha
for servicio in db wordpress; do
  if ! docker compose ps --status running --services | grep -qx "$servicio"; then
    echo "ERROR: el servicio '$servicio' no está en marcha. Ejecuta: docker compose up -d" >&2
    exit 1
  fi
done

# 1. Restaurar base de datos
echo "-> Restaurando base de datos..."
gunzip -c "$F_DB" | docker compose exec -T db sh -c '
  : "${WP_DB_USER:?falta WP_DB_USER en .env}" "${WP_DB_NAME:?falta WP_DB_NAME en .env}"
  exec mariadb -u"$WP_DB_USER" -p"$WP_DB_PASSWORD" "$WP_DB_NAME"'

# 2. Restaurar wp-content
echo "-> Restaurando wp-content..."
docker compose exec -T wordpress rm -rf /var/www/html/wp-content
docker compose exec -T wordpress tar -xzf - -C /var/www/html < "$F_WP"
docker compose exec -T wordpress chown -R www-data:www-data /var/www/html/wp-content

echo "OK. Restauración completada con éxito desde la copia $FECHA."
