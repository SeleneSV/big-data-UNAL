#!/bin/bash

# Constantes
SERVICE_NAME="generator-apolo11.service"
TIMER_NAME="generator-apolo11.timer"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
TIMER_FILE="/etc/systemd/system/${TIMER_NAME}"

# Directorio de trabajo
working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# CARGAR CONFIGURACIONES
echo "$working_dir/generator.config"
generator_config_file="$working_dir/generator.config"
if [ -f "$generator_config_file" ]; then
        source "$generator_config_file"
    else
        echo "Archivo de configuración no encontrado. Se usan las configuraciones por defecto."
    fi

echo -e "\nActualizando generador con systemd..."

sudo systemctl stop generator-apolo11.timer
sudo ./create-generator-service.sh
sudo ./create-generator-timer.sh

echo "Recargando el demonio de systemd..."
systemctl daemon-reload

echo "Habilitando e iniciando el timer '${TIMER_NAME}'..."
systemctl enable "${TIMER_NAME}"
systemctl start "${TIMER_NAME}"

echo -e "\nVerificando el estado de los timers..."
systemctl list-timers | grep "${SERVICE_NAME%.service}" || echo "Timer aún no visible, podría tardar un momento."

echo -e "\nProceso completado"
echo -e "El timer '${TIMER_NAME}' ha sido creado y activado."
echo -e "Ahora ejecutará '${SERVICE_NAME}' cada ${ON_UNIT_ACTIVE_SEC}."

