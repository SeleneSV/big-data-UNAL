# CONFIGURACIONES
SERVICE_NAME="reporter-apolo11.service"
TIMER_NAME="reporter-apolo11.timer"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
TIMER_FILE="/etc/systemd/system/${TIMER_NAME}"
EXEC_DATE="16:15:00"

# Gestión de Systemd
echo -e "\nActivando el timer con systemd..."

echo "Recargando el demonio de systemd..."
systemctl daemon-reload

echo "-> Asegurando que el servicio '${SERVICE_NAME}' no se inicie al arranque..."
systemctl disable "${SERVICE_NAME}" &> /dev/null || true

echo "Habilitando e iniciando el timer '${TIMER_NAME}'..."
systemctl enable "${TIMER_NAME}"
systemctl start "${TIMER_NAME}"

echo -e "\nVerificando el estado de los timers..."
systemctl list-timers | grep "${SERVICE_NAME%.service}" || echo "Timer aún no visible, podría tardar un momento."


echo -e "\nProceso completado"
echo -e "El timer '${TIMER_NAME}' ha sido creado y activado."
echo -e "Ahora ejecutará '${SERVICE_NAME}' a las ${EXEC_DATE}."