#!/bin/sh
set -eu

GLPI_ROOT="/var/www/html"
SEED_CONFIG_DIR="/usr/local/share/glpi-config"

mkdir -p \
  "$GLPI_ROOT/config" \
  "$GLPI_ROOT/files" \
  "$GLPI_ROOT/marketplace"

if [ -f "$SEED_CONFIG_DIR/config_db.php" ] && [ ! -f "$GLPI_ROOT/config/config_db.php" ]; then
  cp "$SEED_CONFIG_DIR/config_db.php" "$GLPI_ROOT/config/config_db.php"
fi

if [ -f "$SEED_CONFIG_DIR/glpicrypt.key" ] && [ ! -f "$GLPI_ROOT/config/glpicrypt.key" ]; then
  cp "$SEED_CONFIG_DIR/glpicrypt.key" "$GLPI_ROOT/config/glpicrypt.key"
fi

chown -R www-data:www-data \
  "$GLPI_ROOT/config" \
  "$GLPI_ROOT/files" \
  "$GLPI_ROOT/marketplace"

find "$GLPI_ROOT/config" -type d -exec chmod 775 {} \;
find "$GLPI_ROOT/config" -type f -exec chmod 664 {} \;
find "$GLPI_ROOT/files" -type d -exec chmod 775 {} \;
find "$GLPI_ROOT/files" -type f -exec chmod 664 {} \;
find "$GLPI_ROOT/marketplace" -type d -exec chmod 775 {} \;
find "$GLPI_ROOT/marketplace" -type f -exec chmod 664 {} \;

exec docker-php-entrypoint apache2-foreground
