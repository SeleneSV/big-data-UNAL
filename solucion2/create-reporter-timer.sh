#!/bin/bash

# Salir inmediatamente si un comando falla
set -e

# Constantes
SERVICE_NAME="reporter-apolo11.service"
TIMER_NAME="reporter-apolo11.timer"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
TIMER_FILE="/etc/systemd/system/${TIMER_NAME}"

working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# CARGAR CONFIGURACIONES
reporter_config_file="$working_dir/reporter.config"
if [ -f "$reporter_config_file" ]; then
        source "$reporter_config_file"
else
    echo "Archivo de configuración no encontrado. Se usan las configuraciones por defecto."
    EXEC_DATE="23:59:00"
fi

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
Description=Run Apolo-11 reporter daily

[Timer]
# Ejecuta todos los días a las $EXEC_DATE
OnCalendar=*-*-* $EXEC_DATE
Persistent=true
Unit=reporter-apolo11.service

[Install]
WantedBy=timers.target
EOF

chmod 644 "${TIMER_FILE}"
echo "Archivo de timer creado con éxito."



