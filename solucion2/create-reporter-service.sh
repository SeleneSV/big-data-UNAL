#!/bin/bash

# Salir si un comando falla
set -e
set -o pipefail

# Directorio de trabajo
working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# Constantes del Servicio
CONSOLIDATOR_SCRIPT_PATH="$working_dir/consolidado.sh"
REPORTER_SCRIPT_PATH="$working_dir/reportes.sh"
SERVICE_NAME="reporter-apolo11.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"

# Validación de parámetros
echo "Iniciando la configuración del servicio '${SERVICE_NAME}'..."

# Validar existencia y permiso de ejecución de ambos scripts
if [ ! -f "$CONSOLIDATOR_SCRIPT_PATH" ] || [ ! -x "$CONSOLIDATOR_SCRIPT_PATH" ]; then
    echo "Error: El script '$CONSOLIDATOR_SCRIPT_PATH' no existe o no tiene permisos de ejecución."
    exit 1
fi

if [ ! -f "$REPORTER_SCRIPT_PATH" ] || [ ! -x "$REPORTER_SCRIPT_PATH" ]; then
    echo "Error: El script '$REPORTER_SCRIPT_PATH' no existe o no tiene permisos de ejecución."
    exit 1
fi

echo "Ambos scripts existen y tienen permisos de ejecución"


# Creación del archivo de servicio
echo "Creando archivo de servicio en: ${SERVICE_FILE}"

# Escribir el contenido del servicio
cat << EOF > "${SERVICE_FILE}"
[Unit]
Description=Apolo-11 Consolidator and Reporter

[Service]
Type=oneshot

WorkingDirectory=${working_dir}

ExecStart=/bin/bash -c 'source venv/bin/activate && ./consolidado.sh && ./reportes.sh'

User=selene
Group=selene

EOF

# Asignar permisos al archivo de servicio
chmod 644 "${SERVICE_FILE}"

echo "El archivo '${SERVICE_FILE}' ha sido creado correctamente."

