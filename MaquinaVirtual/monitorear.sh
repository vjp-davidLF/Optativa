#!/bin/bash

# Script de gestión de procesos y backups con menú interactivo

# Función: Listar procesos con paginación
listar_procesos() {
    clear
    echo "=== Listado de Procesos del Sistema ==="
    ps aux | less
}

# Función: Terminar un proceso
terminar_proceso() {
    clear
    echo "=== Terminar Proceso ==="
    read -p "¿Deseas terminar un proceso? (s/n): " respuesta
    
    if [[ $respuesta == "s" || $respuesta == "S" ]]; then
        read -p "Introduce el PID del proceso a terminar: " pid
        
        # Verificar si el proceso existe
        if ps -p $pid > /dev/null 2>&1; then
            kill $pid
            echo "Proceso $pid terminado."
        else
            echo "Error: El proceso con PID $pid no existe."
        fi
    fi
    
    read -p "Presiona [Enter] para continuar..."
}

# Función: Monitorizar un proceso
monitorizar_proceso() {
    clear
    echo "=== Monitorizar Proceso ==="
    read -p "Introduce el nombre del proceso a monitorizar: " nombre_proceso
    
    # Verificar si existe el proceso
    if pgrep -x "$nombre_proceso" > /dev/null; then
        echo "Monitorizando $nombre_proceso (Ctrl+C para salir)..."
        sleep 2
        
        # Bucle infinito que actualiza cada 5 segundos
        while true; do
            clear
            echo "=== Monitoreo: $nombre_proceso ==="
            echo "Actualizado cada 5 segundos (Ctrl+C para salir)"
            echo ""
            ps aux | grep "$nombre_proceso" | grep -v grep | awk '{print "PID: "$2" | Usuario: "$1" | CPU: "$3"% | Memoria: "$4"% | Comando: "$11}'
            sleep 5
        done
    else
        echo "Error: El proceso '$nombre_proceso' no existe."
        read -p "Presiona [Enter] para continuar..."
    fi
}

# Función: Programar copia de seguridad
programar_backup() {
    clear
    echo "=== Programar Copia de Seguridad ==="
    
    read -p "Ruta absoluta del directorio a respaldar: " origen
    
    # Verificar que el directorio existe
    if [[ ! -d "$origen" ]]; then
        echo "Error: El directorio '$origen' no existe."
        read -p "Presiona [Enter] para continuar..."
        return
    fi
    
    read -p "Ruta absoluta del directorio de destino: " destino
    mkdir -p "$destino"
    
    echo ""
    echo "Selecciona la frecuencia:"
    echo "1. Diario (02:00h)"
    echo "2. Semanal (Domingos a las 03:00h)"
    echo "3. Mensual (Día 1 a las 04:00h)"
    read -p "Opción [1-3]: " freq
    
    # Asignar schedule de cron según frecuencia
    case $freq in
        1) cron_schedule="0 2 * * *" ;;
        2) cron_schedule="0 3 * * 0" ;;
        3) cron_schedule="0 4 1 * *" ;;
        *) 
            echo "Opción no válida."
            read -p "Presiona [Enter] para continuar..."
            return ;;
    esac
    
    # Crear el comando de backup
    backup_file="$destino/backup_$(basename $origen)_\$(date +\%Y-\%m-\%d).tar.gz"
    command="tar -czf $backup_file $origen"
    cron_job="$cron_schedule $command"
    
    # Añadir la tarea a crontab
    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    
    if [[ $? -eq 0 ]]; then
        echo ""
        echo "✓ Backup programado con éxito."
        echo "Tarea añadida: $cron_job"
    else
        echo "✗ Error al programar la tarea en cron."
    fi
    
    read -p "Presiona [Enter] para continuar..."
}

# Función: Mostrar menú principal
mostrar_menu() {
    clear
    echo "╔════════════════════════════════════════╗"
    echo "║   Gestor de Procesos y Backups        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "1. Listar procesos"
    echo "2. Terminar un proceso"
    echo "3. Monitorizar un proceso"
    echo "4. Programar copia de seguridad"
    echo "5. Salir"
    echo ""
    read -p "Selecciona una opción [1-5]: " opcion
}

# Función: Bucle principal
main() {
    while true; do
        mostrar_menu
        
        case $opcion in
            1) listar_procesos ;;
            2) terminar_proceso ;;
            3) monitorizar_proceso ;;
            4) programar_backup ;;
            5) 
                echo "¡Hasta luego!"
                exit 0 ;;
            *)
                echo "Opción no válida. Intenta de nuevo."
                read -p "Presiona [Enter] para continuar..."
                ;;
        esac
    done
}

# Ejecutar el script
main
