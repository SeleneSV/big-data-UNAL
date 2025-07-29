#!/bin/bash

set -e

working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

SCRIPT_PATH="$working_dir/apolo_11.sh"

# CARGAR CONFIGURACIONES
generator_config_file="$working_dir/generator.config"
if [ -f "$generator_config_file" ]; then
        source "$generator_config_file"
    else
        echo "Archivo de configuración no encontrado. Se usan las configuraciones por defecto."
        USE_FLOCK="true"
    fi

# Constantes del Servicio
SERVICE_NAME="generator-apolo11.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"

# Validación de parámetros
echo "Iniciando la configuración del servicio '${SERVICE_NAME}'..."

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Error: El script del generador no se encuentra en la ruta especificada: ${SCRIPT_PATH}"
    exit 1
fi

if [ ! -x "$SCRIPT_PATH" ]; then
    echo "Error: El script '${SCRIPT_PATH}' no tiene permisos de ejecución."
    exit 1
fi

# Determinar el comando de ejecución
if [ "${USE_FLOCK}" = "true" ]; then
    LOCK_FILE="/var/lock/${SERVICE_NAME}.lock"
    EXEC_START="/usr/bin/flock -n ${LOCK_FILE} ${SCRIPT_PATH}"
    echo "Configurando servicio con control de concurrencia (flock)."
else
    EXEC_START="${SCRIPT_PATH}"
    echo "Configurando servicio en modo simple (sin flock)."
fi

# Creación del archivo de servicio
echo "Creando archivo de servicio en: ${SERVICE_FILE}"


if [ "$REPORTER_ACTIVE" = "false" ]; then

# Escribir el contenido del servicio
cat << EOF > "${SERVICE_FILE}"
[Unit]
Description=Servicio que ejecuta el script de generación de datos simulados
# Descomentar si el script necesita red
# After=network.target

[Service]
Type=oneshot
ExecStart=${EXEC_START}

[Install]
# Habilita el servicio para que se inicie en el arranque del sistema (o contenedor)
# WantedBy=multi-user.target
EOF

else
# Escribir el contenido del servicio
cat << EOF > "${SERVICE_FILE}"
[Unit]
Description=Servicio que ejecuta el script de generación de datos simulados
# Descomentar si el script necesita red
# After=network.target
OnSuccess=reporter-apolo11.service

[Service]
Type=oneshot
ExecStart=${EXEC_START}

[Install]
# Habilita el servicio para que se inicie en el arranque del sistema (o contenedor)
# WantedBy=multi-user.target
EOF
fi

# Asignar permisos al archivo de servicio
chmod 644 "${SERVICE_FILE}"

echo "El archivo '${SERVICE_FILE}' ha sido creado correctamente."
