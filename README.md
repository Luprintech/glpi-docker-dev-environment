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

## Tabla de contenidos

- [Aviso de Seguridad](#️-aviso-de-seguridad)
- [Servicios](#servicios)
- [Requisitos](#requisitos)
- [Uso rapido](#uso-rapido)
- [Como funciona](#como-funciona)
- [Persistencia](#persistencia)
- [Acceso a GLPI](#acceso-a-glpi)
- [Acceso a PhpMyAdmin](#acceso-a-phpmyadmin)
- [Que hacer si aparece el instalador](#que-hacer-si-aparece-el-instalador)
- [DevContainer](#devcontainer)
- [Xdebug y Depuración con VS Code](#-xdebug-y-depuración-con-vs-code)
- [Archivos de configuración sensibles](#-archivos-de-configuración-sensibles)
- [Datos incluidos en la base](#datos-incluidos-en-la-base)
- [Estructura relevante del proyecto](#estructura-relevante-del-proyecto)

---

## ⚠️ Aviso de Seguridad

> **ANTES DE USAR EN PRODUCCIÓN O COMPARTIR CON COMPAÑEROS:**
>
> 1. **Cambia TODAS las contraseñas** del archivo `.env` por contraseñas complejas (mínimo 20 caracteres con mayúsculas, minúsculas, números y símbolos).
> 2. **Cambia la contraseña del administrador GLPI** (`glpi` / `glpi`) en el primer acceso: *Configuración → Usuarios → glpi → Contraseña*.
> 3. **Actualiza `glpi_config/config_db.php`** con la nueva contraseña de `MARIADB_PASSWORD`.
> 4. **Deshabilita Xdebug** en producción (ver sección [Xdebug](#-xdebug-y-depuración-con-vs-code)).
> 5. **Haz un backup seguro** del archivo `glpi_config/glpicrypt.key`. Si se pierde, los datos encriptados en la BD quedarán ilegibles.

---

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

---

## 🐛 Xdebug y Depuración con VS Code

### Configuración incluida

El entorno incluye Xdebug 3.x preconfigurado para depuración remota con VS Code:

| Archivo | Propósito |
|---------|-----------|
| `xdebug.ini` | Perfil **desarrollo** — Xdebug activo con modo debug |
| `xdebug.prod.ini` | Perfil **producción** — Xdebug desactivado (`mode=off`) |
| `.vscode/launch.json` | Configuración de debug para VS Code |
| `.devcontainer/devcontainer.json` | Extensiones VS Code instaladas automáticamente |

### Cómo usar el debugger

1. Abre la carpeta del proyecto en VS Code
2. Cuando VS Code ofrezca "Reopen in Container", acepta (o usa `Ctrl+Shift+P` → *Dev Containers: Reopen in Container*)
3. Ve a **Run & Debug** (`Ctrl+Shift+D`)
4. Selecciona **"Escuchar Xdebug"** y pulsa **F5**
5. Pon breakpoints en el código PHP haciendo clic en el margen izquierdo
6. Recarga la página en el navegador — la ejecución se detendrá en el breakpoint

### ⚠️ Por qué deshabilitar Xdebug en producción

Xdebug **nunca debe estar activo en producción** por tres razones críticas:

1. **Rendimiento**: Introduce un overhead constante que puede ralentizar PHP entre un 100% y un 300%, afectando a todos los usuarios del sistema.
2. **Seguridad**: Expone stack traces completos con información interna del servidor (rutas, variables, datos sensibles) en los mensajes de error.
3. **Superficie de ataque**: El puerto 9003 queda abierto. Cualquier cliente en la red puede conectarse al debugger y controlar la ejecución del servidor de forma remota.

### Cómo deshabilitarlo para producción

**Opción A — Sustituir el ini (recomendado):**
En el `dockerfile`, cambiar la línea:
```dockerfile
COPY xdebug.ini /usr/local/etc/php/conf.d/99-xdebug.ini
```
por:
```dockerfile
COPY xdebug.prod.ini /usr/local/etc/php/conf.d/99-xdebug.ini
```
Y reconstruir la imagen: `docker compose build --no-cache glpi`

**Opción B — Variable de entorno en docker-compose.yml:**
Añadir al servicio `glpi`:
```yaml
environment:
  XDEBUG_MODE: "off"
```

---

## 🔐 Archivos de configuración sensibles

| Archivo | En Git | Descripción |
|---------|--------|-------------|
| `.env` | ❌ No | Contraseñas del entorno. **Nunca subir a Git.** |
| `.env.example` | ✅ Sí | Plantilla pública sin contraseñas reales |
| `glpi_config/config_db.php` | ❌ No | Credenciales de BD para GLPI |
| `glpi_config/glpicrypt.key` | ❌ No | Clave de encriptación. **Hacer backup.** |

> **glpicrypt.key**: Esta clave encripta datos sensibles en la base de datos (contraseñas de cuentas externas, tokens API, etc.). Si se pierde o se regenera con datos existentes, esos datos quedarán ilegibles permanentemente. Guarda una copia en un lugar seguro.

---

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
* `xdebug.ini`: configuracion de Xdebug para desarrollo
* `xdebug.prod.ini`: configuracion de Xdebug para produccion (desactivado)
* `.env.example`: plantilla de variables de entorno
