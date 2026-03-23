# GLPI 11.0.6 - Entorno Docker reproducible

## Descripcion

Este proyecto prepara un entorno reproducible de GLPI 11.0.6 para desarrollo y pruebas con Docker Compose.

Incluye:

* GLPI 11.0.6
* MariaDB 10.6
* PhpMyAdmin
* Persistencia con volumenes Docker
* Soporte para DevContainer
* Carga automatica de datos iniciales
* Debug PHP con Xdebug

## Servicios

* GLPI: `http://127.0.0.1:8085`
* PhpMyAdmin: `http://127.0.0.1:8086`
* Xdebug: puerto `9003`

## Requisitos

* Docker Desktop
* Docker Compose
* VS Code (opcional)

## Uso rapido

Primera puesta en marcha o reconstruccion completa del entorno:

```bash
docker compose up -d --build
```

Arranque normal manteniendo los datos ya existentes:

```bash
docker compose up -d
```

Parada del entorno manteniendo los datos:

```bash
docker compose down
```

Restauracion completa al estado inicial incluido en el proyecto:

```bash
docker compose down -v
docker compose up -d --build
```

## Como funciona

El servicio `glpi` espera a que MariaDB este saludable antes de arrancar, por lo que no deberia ser necesario instalar GLPI manualmente ni recargar varias veces la pagina.

La base de datos inicial se carga automaticamente desde:

* `initdb/datos-iniciales.sql`

Esto ocurre solo cuando el volumen `db_data` esta vacio. Si la base ya existe, MariaDB no vuelve a ejecutar los scripts de inicializacion.

## Persistencia

Se utilizan volumenes Docker para conservar la informacion:

* Base de datos: `db_data`
* Configuracion GLPI: `glpi_config`
* Archivos subidos y generados: `glpi_files`
* Plugins y marketplace: `glpi_marketplace`

El contenedor de GLPI copia automaticamente `config_db.php` y `glpicrypt.key` al volumen `glpi_config` si no existen y corrige permisos en cada arranque.

La carpeta `glpi_config/` incluida en el proyecto corresponde a esta instalacion validada. Si durante el desarrollo se genero una carpeta `glpi_config_backup`, ya puede eliminarse una vez comprobado que `docker compose down -v` seguido de `docker compose up -d --build` arranca correctamente y carga los datos de `initdb`.

## Acceso a GLPI

Usuario administrador inicial:

* Usuario: `glpi`
* Contrasena: `glpi`

Usuarios de prueba cargados automaticamente desde `initdb/datos-iniciales.sql`:

* Self-service: `usuario1` / `usuario1`
* Self-service: `usuario2` / `usuario2`
* Self-service: `usuario3` / `usuario3`
* Technician: `desarrollo1` / `desarrollo1`
* Technician: `soporte1` / `soporte1`
* Technician: `sistemas1` / `sistemas1`

## Acceso a PhpMyAdmin

* Servidor: `mariadb`
* Usuario: `root`
* Contrasena: `root`

## Que hacer si aparece el instalador

Si GLPI muestra el instalador web o parece haber perdido la configuracion, normalmente significa que los volumenes persistentes vienen de una ejecucion anterior que no corresponde con el estado actual del proyecto.

En ese caso:

```bash
docker compose down -v
docker compose up -d --build
```

## DevContainer

El proyecto incluye configuracion para abrirlo directamente desde VS Code:

1. Abre la carpeta en VS Code.
2. Ejecuta `Reopen in Container`.

El contenedor de desarrollo utiliza el servicio `glpi` definido en `docker-compose.yml`.

## Debug con Xdebug

Xdebug esta instalado y configurado en el contenedor PHP.

Configuracion relevante:

* Puerto: `9003`
* `xdebug.mode=debug,develop`
* Inicio automatico de sesion de debug en cada peticion

En VS Code basta con tener la extension `xdebug.php-debug` y escuchar en el puerto `9003`.

## Datos incluidos en la base

El seed actual contiene, entre otros elementos:

* Grupos `DSI`, `DESARROLLO`, `SOPORTE AL USUARIO` y `SISTEMAS Y COMUNICACIONES`
* Usuarios self-service y tecnicos
* Desplegables importados
* Activos y relaciones de ejemplo
* Tickets de prueba

## Estructura relevante del proyecto

* `docker-compose.yml`: orquestacion de servicios
* `dockerfile`: imagen personalizada de GLPI
* `docker-entrypoint-glpi.sh`: siembra de configuracion y permisos al arrancar
* `initdb/datos-iniciales.sql`: base de datos inicial reproducible
* `glpi_config/`: configuracion persistente inicial de GLPI
* `.devcontainer/devcontainer.json`: soporte para VS Code DevContainer
