# Verificar el modo del reporter
# Directorio de trabajo
working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GENERATOR_CONFIG_FILE="$working_dir/generator.config"
REPORTER_CONFIG_FILE="$working_dir/generator.config"

# CONFIGURACIONES
GENERATOR_SERVICE_NAME="generator-apolo11.service"
GENERATOR_TIMER_NAME="generator-apolo11.timer"
REPORTER_SERVICE_NAME="reporter-apolo11.service"
REPORTER_TIMER_NAME="reporter-apolo11.timer"

# CARGAR CONFIGURACIONES
system_config_file="$working_dir/system.config"
if [ -f "$system_config_file" ]; then
        source "$system_config_file"
    else
        echo "Archivo de configuración no encontrado. Se usan las configuraciones por defecto."
        MODE=0
        EXEC_DATE="23:59:00"
        ON_UNIT_ACTIVE_SEC="20s"
    fi

# Si el reporte es realtime
if [ $MODE -eq 0 ]; then
    
# Actualizar generator config con exec_time de config del sistema y actualizar reporter_active
cat << EOF > "${GENERATOR_CONFIG_FILE}"
USE_FLOCK="true"
ON_UNIT_ACTIVE_SEC=$ON_UNIT_ACTIVE_SEC
REPORTER_ACTIVE="true"
EOF

# Se activa el timer del generador con reporter_active true
echo -e "\nActualizando generador con systemd..."

sudo systemctl stop generator-apolo11.timer
sudo ./create-generator-service.sh
sudo ./create-generator-timer.sh

echo "Recargando el demonio de systemd..."
systemctl daemon-reload

echo "Habilitando e iniciando el timer '${GENERATOR_TIMER_NAME}'..."
systemctl enable "${GENERATOR_TIMER_NAME}"
systemctl start "${GENERATOR_TIMER_NAME}"

echo -e "\nVerificando el estado de los timers..."
systemctl list-timers | grep "${GENERATOR_SERVICE_NAME%.service}" || echo "Timer aún no visible, podría tardar un momento."

echo -e "\nProceso completado"
echo -e "El timer '${GENERATOR_TIMER_NAME}' ha sido creado y activado."
echo -e "Ahora ejecutará '${GENERATOR_SERVICE_NAME}' cada ${ON_UNIT_ACTIVE_SEC}."


else

# Actualizar reporter con config con exec_date de config del sistema y 
cat << EOF > "${REPORTER_CONFIG_FILE}"
MODE=$MODE
EXEC_DATE=$EXEC_DATE
EOF

# Actualizar generator con reporter_active false
cat << EOF > "${GENERATOR_CONFIG_FILE}"
USE_FLOCK="true"
ON_UNIT_ACTIVE_SEC=$ON_UNIT_ACTIVE_SEC
REPORTER_ACTIVE="false"
EOF

# Se activa el timer del generador con reporter_Active False
echo -e "\nActualizando generador con systemd..."

sudo systemctl stop generator-apolo11.timer
sudo ./create-generator-service.sh
sudo ./create-generator-timer.sh

echo "Recargando el demonio de systemd..."
systemctl daemon-reload

echo "Habilitando e iniciando el timer '${GENERATOR_TIMER_NAME}'..."
systemctl enable "${GENERATOR_TIMER_NAME}"
systemctl start "${GENERATOR_TIMER_NAME}"

echo -e "\nVerificando el estado de los timers..."
systemctl list-timers | grep "${GENERATOR_SERVICE_NAME%.service}" || echo "Timer aún no visible, podría tardar un momento."

echo -e "\nProceso completado"
echo -e "El timer '${GENERATOR_TIMER_NAME}' ha sido creado y activado."
echo -e "Ahora ejecutará '${GENERATOR_SERVICE_NAME}' cada ${ON_UNIT_ACTIVE_SEC}."


# Se activa el timer del reporter
echo -e "\nActualizando reporter con systemd..."

sudo systemctl stop reporter-apolo11.timer
sudo ./create-reporter-timer.sh

echo "Recargando el demonio de systemd..."
systemctl daemon-reload

echo "Habilitando e iniciando el timer '${REPORTER_TIMER_NAME}'..."
systemctl enable "${REPORTER_TIMER_NAME}"
systemctl start "${REPORTER_TIMER_NAME}"

echo -e "\nVerificando el estado de los timers..."
systemctl list-timers | grep "${REPORTER_SERVICE_NAME%.service}" || echo "Timer aún no visible, podría tardar un momento."

echo -e "\nProceso completado"
echo -e "El timer '${REPORTER_TIMER_NAME}' ha sido creado y activado."
echo -e "Ahora se ejecutará '${REPORTER_SERVICE_NAME}' a las ${EXEC_DATE}."

fi



