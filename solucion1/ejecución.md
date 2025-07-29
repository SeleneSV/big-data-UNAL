# Flujo de trabajo

## 1. Preparar los archivos

Asegurar de tener los archivos en el mismo directorio:

- `apolo_11.sh`
- `consolidado.sh`
- `reportes.sh`
- `create-generator-service.sh`
- `create-generator-timer.sh`
- `create-reporter-service.sh`
- `create-reporter-timer.sh`

## 2. Asignar permisos de ejecución

```bash
chmod +x apolo_11.sh
chmod +x consolidado.sh
chmod +x reportes.sh
chmod +x create-generator-service.sh
chmod +x create-generator-timer.sh
chmod +x create-reporter-service.sh
chmod +x create-reporter-timer.sh
```

## 3. Ejecutar los Scripts de Creación (con sudo)

1. Crear los servicios:

```bash
sudo ./create-generator-service.sh
sudo ./create-reporter-service.sh
```

2. Crear el timer

```bash
sudo ./create-generator-timer.sh
sudo ./create-reporter-timer.sh
```

## 4. Ejecutar servicio para probar funcionamiento

1. Generator

```bash
sudo systemctl start generator-apolo11.service
```

2. Reporter

```bash
sudo systemctl start reporter-apolo11.service
```

## 5. Ejecutar timer para automatizar ejecución

```bash
sudo bash ./execute_generator.sh
```

```bash
sudo bash ./execute_daily_reporter.sh
```

## 6. Validar ejecución del timer

Verificar el estado
```bash
sudo systemctl status generator-apolo11.timer
sudo systemctl status reporter-apolo11.timer
```

Listar los timers activos:
```bash
sudo systemctl list-timers
```

Ver los logs en tiempo real:
```bash
sudo journalctl -u generator-apolo11.service -f
sudo journalctl -u reporter-apolo11.service -f
```

## 7. Detener el timer

1. Para detener el timer temporalmente
```bash
sudo systemctl stop generator-apolo11.timer
```

2. Para detener permanentemente (Incluso después de reiniciar) 

```bash
sudo systemctl stop generator-apolo11.timer
sudo systemctl disable generator-apolo11.timer
```

o

```bash
sudo systemctl disable --now generator-apolo11.timer
```


## Activar el timer

Si se detuvo el timer:
```bash
sudo systemctl start generator-apolo11.timer
```

Si se desactivo el timer (para tomar las configuraciones ejecutar con el paso 5)

```bash
sudo systemctl enable --now generator-apolo11.timer
```
