#!/bin/bash

working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

config_file="$working_dir/controlador.conf"
apolo_11_script="$working_dir/apolo_11.sh"
consolidado_script="$working_dir/consolidado.sh"
reportes_script="$working_dir/reportes.sh"

echo "Iniciando controlador de simulador..."

# Bucle infinito
while true; do
    # Cargar la config
    if [ -f "$config_file" ]; then
        source "$config_file"
    else
        echo "Archivo de configuración no encontrado. Se usan las configuraciones por defecto."
        exec_freq=20
    fi

    echo "Ejecutando Apolo 11..."

    # Ejecutar Apolo 11 script
    bash "$apolo_11_script"
    bash "$consolidado_script"
    bash "$reportes_script"

    sleep "$exec_freq"

    echo "Próxima ejecución en $exec_freq segundos."
done