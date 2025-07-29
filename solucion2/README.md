# Sistema de Simulación y Análisis de Logs Apolo 11

Este proyecto implementa un sistema automatizado para la generación, consolidación y análisis de logs de misiones espaciales simuladas. El sistema utiliza scripts de Bash y se orquesta mediante servicios y timers de `systemd`, permitiendo una operación continua y programada.

La principal característica del sistema es su capacidad de ser configurado en tiempo real a través de archivos de configuración, lo que permite modificar su comportamiento sin necesidad de alterar los scripts principales.

## Características Principales

- **Generación de Logs Dinámica:** Crea archivos de log simulando eventos de diferentes misiones y dispositivos.
- **Automatización con `systemd`:** Utiliza servicios y timers para automatizar todo el flujo de trabajo, desde la generación hasta el reporte.
- **Dos Modos de Operación:**
  1.  **Tiempo Real:** Los reportes se generan inmediatamente después de cada ciclo de generación de logs.
  2.  **Programado (Diario):** Los reportes se consolidan y generan una vez al día a una hora específica.
- **Configuración en tiempo casi real:** Permite cambiar la frecuencia de ejecución, los parámetros de los logs y el modo de operación modificando archivos de configuración y actualizando los servicios sin detener el sistema por completo.
- **Análisis de Datos:** Genera reportes detallados sobre el estado de las misiones, desconexiones, dispositivos inoperables y estadísticas porcentuales.
- **Gestión de Archivos:** Organiza automáticamente los logs generados, consolidados, reportes y backups en directorios específicos.

## Arquitectura del Sistema

El sistema sigue un flujo de trabajo claro y modular:

1.  **Generación (`Apolo11.sh`):** Un `timer` de `systemd` (`generator-apolo11.timer`) activa periódicamente el servicio `generator-apolo11.service`. Este servicio ejecuta `Apolo11.sh`, que crea un número aleatorio de archivos de log en el directorio `devices/`.
2.  **Consolidación y Reporte (`consolidado.sh` y `reportes.sh`):** La ejecución de este paso depende del modo de operación configurado:
    *   **Modo Tiempo Real:** El servicio `generator-apolo11.service` está configurado para que, al terminar con éxito (`OnSuccess`), active inmediatamente el `reporter-apolo11.service`.
    *   **Modo Programado:** Un `timer` independiente (`reporter-apolo11.timer`) se activa a una hora predefinida (ej. 23:59:00) para lanzar el `reporter-apolo11.service`.
3.  **Procesamiento de Reportes:** El `reporter-apolo11.service` ejecuta secuencialmente:
    *   `consolidado.sh`: Lee todos los logs de `devices/` y los une en un único archivo en `consolidados/`.
    *   `reportes.sh`: Analiza el archivo consolidado usando `csvkit` para generar múltiples reportes en `reportes/`.
4.  **Limpieza:** Una vez generados los reportes, `reportes.sh` mueve los logs individuales procesados desde `devices/` al directorio `backups/`, dejando el sistema listo para el siguiente ciclo.

## Estructura de Archivos y Directorios

```
/
├── devices/          # Directorio de salida para logs individuales generados.
├── consolidados/     # Almacena los logs consolidados por ejecución.
├── reportes/         # Contiene los reportes de análisis generados.
├── backups/          # Guarda los logs individuales después de ser procesados.
├── venv/             # (Recomendado) Entorno virtual de Python para dependencias.
|
├── Apolo11.sh                # Script principal de generación de logs.
├── consolidado.sh            # Script para consolidar logs.
├── reportes.sh               # Script para generar reportes de análisis.
|
├── create-generator-service.sh   # Crea el archivo .service del generador.
├── create-generator-timer.sh     # Crea el archivo .timer del generador.
├── create-reporter-service.sh    # Crea el archivo .service del reportador.
├── create-reporter-timer.sh      # Crea el archivo .timer del reportador.
|
├── execute_generator.sh      # (Obsoleto) Usar monitoring_system.sh
├── execute_daily_reporter.sh # (Obsoleto) Usar monitoring_system.sh
|
├── monitoring_system.sh      # Script principal para configurar y cambiar el modo del sistema.
├── update_generator.sh       # Script para aplicar cambios en la configuración del generador.
├── update_reporter.sh        # Script para aplicar cambios en la configuración del reportador.
|
├── apolo_11.config           # Configuración para la generación de logs (misiones, dispositivos).
├── system.config             # Configuración maestra del sistema (modo, tiempos).
├── generator.config          # (Autogenerado) Configuración para el servicio/timer del generador.
└── reporter.config           # (Autogenerado) Configuración para el servicio/timer del reportador.
```

## Prerrequisitos

Antes de instalar, se deben tener los siguientes componentes en el sistema:

- **`bash`**: Intérprete de comandos estándar.
- **`systemd`**: Sistema de inicio y gestión de servicios.
- **`python3`** y **`pip`**: Para instalar dependencias.
- **`csvkit`**: Conjunto de herramientas de línea de comandos para trabajar con archivos CSV.


### Instalación de `csvkit` (Dependencia para Reportes)

Se puede instalar `csvkit` de dos manera:

**Opcion 1 (Recomendado): Usando un Entorno Virtual (venv)**

El sistema está preconfigurado para esta opción.

1. Navegar al directiorio raíz del proyecto.
2. Crear el entorno virtual:

```bash
# Crear un entorno virtual
python3 -m venv venv
```

3. Activar el entrono e instalar `csvkit`:
```bash
# Activar el entorno virtual
source venv/bin/activate

# Instalar csvkit
pip install csvkit

# Se puede desactivar con `deactivate`
```

4. No se necesita ningún cambio adicional. El servicio `reoirter-apolo11.service` está configurado por defecto para usar este entorno.

**Opción 2 (Alternativa): Instalación Global**

Si se prefiere intalar `csvkit` a nivel de sistema o ya está instalado:

1. Instala csvkit globalmente

```bash
pip install csvkit
```

2. **Paso Crítico**: Se debe modificar el script que crea el servicio para que no intente activar el entorno virtual.
- Abrir el archivo create-reporter-service.sh.
- Buscar la línea ExecStart.
- Cámbiar de:

```bash
ExecStart=/bin/bash -c 'source venv/bin/activate && ./consolidado.sh && ./reportes.sh'
```
A
```bash
ExecStart=/bin/bash -c './consolidado.sh && ./reportes.sh'
```

Si no se realiza este cambio, el servicio fallará al no encontrar el directorio `venv/`.

## Instalación y Puesta en Marcha

1.  **Clonar el Repositorio:**
    Obtener todos los scripts del proyecto en entorno local.

2.  **Dar Permisos de Ejecución:**
    Se debe asegurar de que todos los scripts `.sh` tengan permisos de ejecución.

    ```bash
    chmod +x *.sh
    ```

3.  **Configuración Inicial:**
    Editar el archivo `system.config` para definir el modo de operación inicial.

    **Ejemplo: Modo Tiempo Real (cada 30 segundos)**
    ```ini
    # system.config
    MODE=0
    ON_UNIT_ACTIVE_SEC="30s"
    EXEC_DATE="23:59:00" # No se usa en este modo, pero debe estar presente
    ```

    **Ejemplo: Modo Programado (diario a las 23:30)**
    ```ini
    # system.config
    MODE=1
    ON_UNIT_ACTIVE_SEC="5m" # Frecuencia de generación de logs
    EXEC_DATE="23:30:00"    # Hora de generación de reportes
    ```
    También es posible personalizar `apolo_11.config` para cambiar los nombres de las misiones, tipos de dispositivos, etc.

4.  **Crear y Activar los Servicios:**
    El script `monitoring_system.sh` se encarga de todo. Lee el archivo `system.config`, crea los archivos de servicio y timer correspondientes, y los activa.

    ```bash
    # Ejecutar con sudo para que pueda crear/modificar archivos en /etc/systemd/system/
    sudo ./monitoring_system.sh
    ```
    Este comando instalará y arrancará los timers según la configuración definida.

## Uso y Configuración

La principal ventaja del sistema es su flexibilidad. A continuación se describe cómo gestionarlo.

### Cambiar el Modo de Operación

Para cambiar entre el modo "Tiempo Real" y "Programado", o para ajustar los tiempos de ejecución:

1.  **Editar `system.config`**: Modificar los valores de `MODE`, `ON_UNIT_ACTIVE_SEC` o `EXEC_DATE` según las necesidades.
2.  **Aplicar los Cambios**: Volver a ejecutar `monitoring_system.sh` para que reconfigure los servicios y timers de `systemd`.

    ```bash
    sudo ./monitoring_system.sh
    ```
    El script detendrá los timers antiguos, regenerará los archivos de configuración de los servicios y activará los nuevos timers.

### Actualizar Parámetros de Generación

Si solo se desea cambiar los parámetros de los logs (ej. añadir una nueva misión):

1.  **Editar `apolo_11.config`**: Realizar los cambios necesarios.
2.  Estos cambios se aplicarán automáticamente en el siguiente ciclo de ejecución de `Apolo11.sh`, no es necesario reiniciar ningún servicio.

### Actualización Selectiva de Timers

Si se prefiere actualizar solo un componente (generador o reporter) después de cambiar `system.config`:

-   Para aplicar cambios solo al generador:
    ```bash
    sudo ./update_generator.sh
    ```
-   Para aplicar cambios solo al reportador (en modo programado):
    ```bash
    sudo ./update_reporter.sh
    ```

## Monitoreo y Verificación

Para asegurarse de que el sistema funcione correctamente, se puede usar los siguientes comandos:

-   **Listar todos los timers activos e inactivos:**
    ```bash
    systemctl list-timers --all
    ```
    Busca `generator-apolo11.timer` y `reporter-apolo11.timer` en la lista para ver cuándo se ejecutarán la próxima vez.

-   **Ver los logs de un servicio en tiempo real:**
    Depurar y ver la salida de los scripts.

    -   Para el servicio generador:
        ```bash
        sudo journalctl -u generator-apolo11.service -f
        ```
    -   Para el servicio de reportes:
        ```bash
        sudo journalctl -u reporter-apolo11.service -f
        ```

---