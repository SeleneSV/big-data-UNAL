#!/bin/bash

# Salir si un comando falla
set -e

# Directorio de trabajo
working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# CARGAR CONFIGURACIONES
generator_config_file="$working_dir/generator.config"
if [ -f "$generator_config_file" ]; then
        source "$generator_config_file"
    else
        echo "Archivo de configuración no encontrado. Se usan las configuraciones por defecto."
        ON_UNIT_ACTIVE_SEC="20s"
    fi


# Constantes del servicio
ON_BOOT_SEC="15s"
SERVICE_NAME="generator-apolo11.service"
TIMER_NAME="generator-apolo11.timer"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
TIMER_FILE="/etc/systemd/system/${TIMER_NAME}"

# Validar que el archivo .service asociado existe
if [ ! -f "$SERVICE_FILE" ]; then
    echo -e "Error: El servicio asociado '${SERVICE_NAME}' no existe en ${SERVICE_FILE}"
    exit 1
fi

echo "Servicio asociado encontrado"

# Creación del archivo de timer
echo -e "\nCreando archivo de timer en ${TIMER_FILE}..."

cat << EOF > "${TIMER_FILE}"
[Unit]
Description=Ejecuta ${SERVICE_NAME} cada ${ON_UNIT_ACTIVE_SEC}

[Timer]
# Ejecutar ${ON_BOOT_SEC} después de arrancar y luego periódicamente
OnBootSec=${ON_BOOT_SEC}
# Ejecutar cada ${ON_UNIT_ACTIVE_SEC} después de que la última ejecución terminara
OnUnitActiveSec=${ON_UNIT_ACTIVE_SEC}
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

# Asignar permisos al archivo de servicio
chmod 644 "${TIMER_FILE}"
echo "Archivo de timer creado con éxito."
