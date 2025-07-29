#!/bin/bash

config_file="$(pwd)/generator.conf"
apolo_11_script="$(pwd)/apolo_11.sh"

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

    echo "Ejecutando Apolo 11. Próxima ejecución en $exec_freq segundos."

    # Ejecutar Apolo 11 script
    bash "$apolo_11_script"

    sleep "$exec_freq"
done