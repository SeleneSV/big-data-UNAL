#!/bin/bash

working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# =====================================
# CONFIGURACIÓN
LOGS_DIR="$working_dir/devices"
CONSOLIDATED_DIR="$working_dir/consolidados"
HEADER="date;mission;device_type;device_status;hash"
# =====================================

# Verificar que existan archivos en la carpeta
if [ ! -d "$LOGS_DIR" ]; then
    echo "Error: El directorio de logs '$LOGS_DIR' no existe."
    exit 1
fi

# Crear directorio de consolidado si no existe
if [ -d "$CONSOLIDATED_DIR" ]; then
    echo "La carpeta '$CONSOLIDATED_DIR' ya existe."
else
    echo "Creando '$CONSOLIDATED_DIR'..."
    mkdir -p "$CONSOLIDATED_DIR" && chmod 755 "$CONSOLIDATED_DIR"
fi


echo "Iniciando consolidado por ejecución..."
TIMESTAMP=$(date "+%d%m%Y%H%M%S")
OUTPUT_FILE="${CONSOLIDATED_DIR}/consolidado-${TIMESTAMP}.log"
    
# Escribir el header en el archivo de salida
echo "$HEADER" > "$OUTPUT_FILE"

# Leer la última línea de cada log y guardar en archivo de consolidado
find "$LOGS_DIR" -maxdepth 1 -type f -name "*.log" | while read file; do
    tail -n +2 "$file" >> "$OUTPUT_FILE"
done

# Comprobar si se añadieron datos además del encabezado
if [ $(wc -l < "$OUTPUT_FILE") -gt 1 ]; then
    echo "Logs consolidados en: $OUTPUT_FILE"
else
    echo "No se encontraron archivos .log con datos en '$LOGS_DIR'."
    rm "$OUTPUT_FILE"
fi


