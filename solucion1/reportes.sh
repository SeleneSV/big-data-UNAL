#!/bin/bash

set -o pipefail

# Directorio de trabajo
working_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# Definición de directorios
LOGS_DIR="$working_dir/devices"
CONSOLIDATED_DIR="$working_dir/consolidados"
REPORTS_DIR="$working_dir/reportes"
BACKUPS_DIR="$working_dir/backups"
DELIMITER=";"

# Buscar consolidado más reciente
echo "Buscando el archivo de consolidado más reciente..."
INPUT_FILE=$(ls -t "$CONSOLIDATED_DIR"/consolidado-*.log 2>/dev/null | head -n 1)

# Validar que se encontró un archivo de consolidado
if [ -z "$INPUT_FILE" ]; then
    echo "Error: No se encontró ningún archivo de consolidado en '$CONSOLIDATED_DIR'."
    exit 1
fi
echo "Procesando archivo: $INPUT_FILE"

# Crear el directorio de reportes y backups si no existen
if [ -d "$REPORTS_DIR" ]; then
    echo "La carpeta '$REPORTS_DIR' ya existe."
else
    echo "Creando '$REPORTS_DIR'..."
    mkdir -p "$REPORTS_DIR" && chmod 755 "$REPORTS_DIR"
fi

if [ -d "$BACKUPS_DIR" ]; then
    echo "La carpeta '$BACKUPS_DIR' ya existe."
else
    echo "Creando '$BACKUPS_DIR'..."
    mkdir -p "$BACKUPS_DIR" && chmod 755 "$BACKUPS_DIR"
fi

# ========================================
# GENERACIÓN DE REPORTES

# timestamp para el nombre de archivo de los reportes
TIMESTAMP=$(date +"%d%m%y%H%M%S")

# Análisis de eventos
echo "Generando reporte: Análisis de Eventos..."
OUTPUT_FILE_EVENTOS="${REPORTS_DIR}/APLSTATS-EVENTOS-${TIMESTAMP}.log"
cat "$INPUT_FILE" | csvsql -d "$DELIMITER" --query "
    SELECT mission, device_type, device_status, COUNT(*) AS event_count
    FROM stdin
    GROUP BY mission, device_type, device_status
    ORDER BY mission, device_type, event_count DESC
" | csvlook > "$OUTPUT_FILE_EVENTOS"

# Gestion de desconexiones
echo "Generando reporte: Gestión de Desconexiones..."
OUTPUT_FILE_DESCONEXIONES="${REPORTS_DIR}/APLSTATS-DESCONEXIONES-${TIMESTAMP}.log"
cat "$INPUT_FILE" | csvsql -d "$DELIMITER" --query "
    SELECT mission, device_type, COUNT(*) AS unknown_count
    FROM stdin
    WHERE device_status = 'unknown'
    GROUP BY mission, device_type
    ORDER BY unknown_count DESC
" | csvlook > "$OUTPUT_FILE_DESCONEXIONES"

# Misiones inoperables
echo "Generando reporte: Consolidación de Misiones..."
OUTPUT_FILE_INOPERABLES="${REPORTS_DIR}/APLSTATS-INOPERABLES-${TIMESTAMP}.log"
cat "$INPUT_FILE" | csvsql -d "$DELIMITER" --query "
    SELECT mission, COUNT(*) AS inoperable_devices
    FROM stdin
    WHERE device_status = 'killed'
    GROUP BY mission
    ORDER BY inoperable_devices DESC
" | csvlook > "$OUTPUT_FILE_INOPERABLES"

# Calculo porcentajes
echo "Generando reporte: Cálculo de Porcentajes..."
OUTPUT_FILE_PORCENTAJES="${REPORTS_DIR}/APLSTATS-PORCENTAJES-${TIMESTAMP}.log"
cat "$INPUT_FILE" | csvsql -d "$DELIMITER" --query "
    SELECT
        mission,
        device_type,
        COUNT(*) AS data_points,
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stdin), 2) AS percentage
    FROM stdin
    GROUP BY mission, device_type
    ORDER BY percentage DESC
" | csvlook > "$OUTPUT_FILE_PORCENTAJES"

echo "Todos los reportes han sido generados en la carpeta: $REPORTS_DIR"

# ==================================================
# MANEJO DE ARCHIVOS PROCESADOS

echo "Iniciando limpieza de logs..."

file_count=$(find "$LOGS_DIR" -maxdepth 1 -type f -name "*.log" | wc -l)

if [ "$file_count" -gt 0 ]; then

    mv "$LOGS_DIR"/*.log "$BACKUPS_DIR/"
    
    echo "Proceso de limpieza completado."
    echo "$file_count archivos de log fueron movidos de '$LOGS_DIR' a '$BACKUPS_DIR'."
else
    echo "No se encontraron archivos .log en '$LOGS_DIR' para mover. No se requiere limpieza."
fi

