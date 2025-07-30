#!/bin/bash

# Directorio de trabajo
working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# ============================
# CARGAR CONFIGURACIONES
apolo_11_config_file="$working_dir/apolo_11.config"
if [ -f "$apolo_11_config_file" ]; then
        source "$apolo_11_config_file"
    else
        echo "Archivo de configuración no encontrado. Se usan las configuraciones por defecto."
        misions_names=("ORBONE" "CLNM" "TMRS" "GALXONE" "UNKN") # Nombres de las misiones
        devices_types=("satellite" "spaceship" "space_vehicle")
        num_logs_range=(1 5)
    fi
# ============================


# ============================
# CONSTANTES
status_options=(excellent good warning faulty killed unknown)
min=1 # valor mínimo para la generación del código
max=100 # Valor máximo para la generación del código
total_misions=${#misions_names[@]}
total_devices=${#devices_types[@]}
total_status=${#status_options[@]}
#==============================


# Crear directorio de salida a partir del directorio actual
output_dir="${working_dir}/devices"
mkdir -p "$output_dir"


# Generación de archivos
# Seleccionar número de archivos a crear
total_logs=$(($RANDOM%(${num_logs_range[1]}-${num_logs_range[0]}+1)+${num_logs_range[0]}))
echo "Total de logs: $total_logs"


echo "Iniciando generación de logs..."
for i in $(seq 1 $total_logs); do
    # Seleccionar nombre de la misión
    apl=${misions_names[$(($RANDOM % $total_misions))]}
    random_num=$(($RANDOM%($max-$min+1)+$min))
    codigo="0000${random_num}"
    output_name="${apl}-${codigo}.log"

    # Seleccionar tipo de dispositivo
    device_type=${devices_types[$(($RANDOM % $total_devices))]}
    status=${status_options[$(($RANDOM % $total_status))]}

    # Fecha-hora actual
    current_date=$(date "+%d%m%Y%H%M%S")

    # Hash
    hash_data="${current_date}|${apl}|${device_type}|${status}"
    hash=$(echo -n "$hash_data" | sha256sum | awk '{print $1}')

    # Verificar si la misión es desconocida
    if [ $apl = "UNKN" ]; then
        device_type="unknown"
        status="unknown"
        hash="unknown"
    fi

    # Guardar archivo
    output_path="$output_dir/$output_name"
    echo "date;mission;device_type;device_status;hash" > $output_path
    echo "$current_date;$apl;$device_type;$status;$hash" >> $output_path
done
