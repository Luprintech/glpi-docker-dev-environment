# GLPI 11.0.6 - Entorno Docker (Versión persistente y preparación de datos)

## 📌 Descripción

Este proyecto despliega un entorno de desarrollo completo de GLPI 11.0.6 mediante Docker Compose.

Incluye:

* GLPI 11.0.6
* MariaDB 10.6
* PhpMyAdmin
* Persistencia de datos
* Soporte para DevContainer
* Preparado para carga automática de datos iniciales

---

## ⚙️ Requisitos

* Docker Desktop
* Docker Compose
* VS Code (opcional)

---

## 🚀 Puesta en marcha

```bash
docker compose up -d --build
```

---

## 🌐 Acceso

* GLPI:
  http://127.0.0.1:8085

* PhpMyAdmin:
  http://127.0.0.1:8086

---

## 🗄️ Persistencia de datos

Se utilizan volúmenes Docker para mantener la información:

* Base de datos → `db_data`
* Configuración GLPI → `glpi_config`
* Archivos → `glpi_files`
* Plugins → `glpi_marketplace`

Esto permite que los datos se mantengan tras reinicios.

---


## 🛠️ Instalación y uso automático

Este entorno está preparado para que GLPI arranque ya instalado y con los datos precargados, sin pasos manuales.

### PASOS PARA USUARIOS/CLIENTES

1. **Arranque inicial:**
  ```bash
  docker compose up -d --build
  ```
  - Accede a GLPI en [http://127.0.0.1:8085](http://127.0.0.1:8085)
  - Si ves un error de conexión SQL, espera 10-30 segundos y recarga la página (la base de datos puede tardar en arrancar la primera vez).

2. **Acceso:**
  - Usuario: `glpi`
  - Contraseña: `glpi`

3. **Persistencia:**
  - Todos los datos y la configuración se guardan en volúmenes Docker. Si apagas y vuelves a levantar, todo sigue igual.

4. **Restaurar a estado inicial (borrar todo y recargar datos):**
  ```bash
  docker compose down -v
  docker compose up -d --build
  ```
  - Esto borra todos los datos y vuelve a cargar la base de datos y la configuración inicial.

### ⚠️ Notas importantes
- Si ves un error de conexión SQL al arrancar, **espera unos segundos y recarga la página**. Es normal la primera vez.
- No es necesario hacer la instalación web de GLPI: el sistema ya está instalado y configurado.
- Si necesitas cambiar los datos iniciales, reemplaza el archivo SQL en `initdb/` y repite el paso de restauración.

---

---

## 🔑 Acceso

* Usuario: `glpi`
* Contraseña: `glpi`

---

## 📊 Población de datos y automatización

✔ Los datos iniciales se cargan automáticamente desde `initdb/datos-iniciales.sql`.
✔ El entorno es completamente reproducible: cualquier usuario puede levantarlo y tener GLPI listo para usar.

---


## 🔄 Reinicio y restauración

- Para reiniciar manteniendo datos:
  ```bash
  docker compose down
  docker compose up -d
  ```
- Para restaurar el estado inicial (borrar todo y recargar datos):
  ```bash
  docker compose down -v
  docker compose up -d --build
  ```

---

---


## 🧠 Consideraciones importantes

- No se utiliza `glpi_config` como carpeta local, sino como volumen Docker.
- Se emplean volúmenes para evitar errores de instalación y asegurar persistencia.
- Si necesitas cambiar la configuración inicial, actualiza el archivo `config-preparado/config_db.php` y/o el SQL de `initdb/` y repite el proceso de restauración.
- Entorno preparado para desarrollo colaborativo y despliegue rápido.

---

---

## 🧪 Debug

Xdebug activo en puerto 9003

---

## 👩‍💻 DevContainer

Permite trabajar directamente en el contenedor:

* Abrir en VS Code
* Ejecutar:
  `Reopen in Container`

---


## 📌 Estado del proyecto

✔ GLPI funcionando
✔ Persistencia correcta
✔ Datos iniciales automáticos
✔ Preparado para despliegue y uso inmediato

---
