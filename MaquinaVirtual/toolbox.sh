#!/bin/bash

# Verifico si el usuario es root, si no es root el script termina
if [[ $EUID -ne 0 ]]; then
   echo "Error: Este script debe ejecutarse como root"
   exit 1
fi

# Función para pausar y que el usuario lea
pausa() {
    read -p "Presiona Enter para continuar..."
}

# OPCIÓN 1: Gestión de Usuarios y Grupos
gestion_usuarios() {
    while true; do
        clear
        echo " GESTIÓN DE USUARIOS Y GRUPOS ==="
        echo "1. Crear usuario"
        echo "2. Eliminar usuario"
        echo "3. Crear grupo"
        echo "4. Asignar usuario a grupo"
        echo "5. Volver"
        read -p "Elige opción: " opt
        
        case $opt in
            1)
                read -p "Nombre del usuario: " user
                # Compruebo si el usuario ya existe
                if id "$user" &>/dev/null; then
                    echo "El usuario ya existe"
                else
                    # Creo el usuario con home y bash
                    useradd -m -s /bin/bash "$user"
                    echo "Usuario creado"
                fi
                pausa
                ;;
            2)
                read -p "Nombre del usuario a eliminar: " user
                # Compruebo si existe antes de eliminar
                if id "$user" &>/dev/null; then
                    userdel -r "$user"
                    echo "Usuario eliminado"
                else
                    echo "El usuario no existe"
                fi
                pausa
                ;;
            3)
                read -p "Nombre del grupo: " group
                # Compruebo si el grupo ya existe
                if getent group "$group" &>/dev/null; then
                    echo "El grupo ya existe"
                else
                    groupadd "$group"
                    echo "Grupo creado"
                fi
                pausa
                ;;
            4)
                read -p "Nombre del usuario: " user
                read -p "Nombre del grupo: " group
                # Agrego el usuario al grupo
                usermod -a -G "$group" "$user"
                echo "Usuario añadido al grupo"
                pausa
                ;;
            5)
                return
                ;;
        esac
    done
}

# OPCIÓN 2: Información de Cuentas
informacion_cuentas() {
    clear
    echo "=== USUARIOS DEL SISTEMA (Primeros 10) ==="
    # Muestro los primeros 10 usuarios del archivo /etc/passwd
    head -n 10 /etc/passwd | cut -d: -f1,3,5
    
    echo ""
    echo "=== GRUPOS DEL SISTEMA (Primeros 10) ==="
    # Muestro los primeros 10 grupos del archivo /etc/group
    head -n 10 /etc/group | cut -d: -f1,3
    pausa
}

# OPCIÓN 3: Gestión de Enlaces
gestion_enlaces() {
    while true; do
        clear
        echo "=== GESTIÓN DE ENLACES ==="
        echo "1. Crear enlace simbólico"
        echo "2. Crear enlace duro"
        echo "3. Volver"
        read -p "Elige opción: " opt
        
        case $opt in
            1)
                read -p "Archivo original: " origen
                read -p "Nombre del enlace: " destino
                # Compruebo si el archivo original existe
                if [[ -e "$origen" ]]; then
                    ln -s "$origen" "$destino"
                    echo "Enlace simbólico creado"
                else
                    echo "El archivo no existe"
                fi
                pausa
                ;;
            2)
                read -p "Archivo original: " origen
                read -p "Nombre del enlace: " destino
                # Compruebo si es un archivo regular
                if [[ -f "$origen" ]]; then
                    ln "$origen" "$destino"
                    echo "Enlace duro creado"
                else
                    echo "El archivo no existe"
                fi
                pausa
                ;;
            3)
                return
                ;;
        esac
    done
}

# OPCIÓN 4: Diagnóstico del Sistema
diagnostico() {
    clear
    echo "=== DIAGNÓSTICO DEL SISTEMA ==="
    echo ""
    echo "Procesador: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
    echo "Núcleos: $(grep -c '^processor' /proc/cpuinfo)"
    echo "RAM Total: $(free -h | grep Mem | awk '{print $2}')"
    echo "RAM Disponible: $(free -h | grep Mem | awk '{print $7}')"
    echo ""
    echo "Kernel: $(uname -r)"
    echo "SO: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
    echo "Hostname: $(hostname)"
    echo "Fecha: $(date)"
    pausa
}

# OPCIÓN 5: Gestión de Software
gestion_software() {
    while true; do
        clear
        echo "=== GESTIÓN DE SOFTWARE ==="
        echo "1. Contar paquetes instalados"
        echo "2. Buscar un paquete"
        echo "3. Volver"
        read -p "Elige opción: " opt
        
        case $opt in
            1)
                # Cuento los paquetes instalados
                echo "Total de paquetes: $(dpkg -l | grep '^ii' | wc -l)"
                pausa
                ;;
            2)
                read -p "Nombre del paquete: " paquete
                # Busco si está instalado
                if dpkg -l | grep -q "^ii.*$paquete"; then
                    echo "El paquete $paquete está instalado"
                    dpkg -l | grep "^ii.*$paquete" | awk '{print $2, $3}'
                else
                    echo "El paquete no está instalado"
                fi
                pausa
                ;;
            3)
                return
                ;;
        esac
    done
}

# OPCIÓN 6: Administración de Discos
administracion_discos() {
    clear
    echo "=== ESQUEMA DE PARTICIONES ==="
    # Muestro las particiones y volúmenes
    lsblk
    
    echo ""
    echo "=== USO DE ESPACIO EN DISCO ==="
    # Muestro el espacio disponible de forma legible
    df -h
    pausa
}

# OPCIÓN 7: Monitorización en Vivo
monitorizacion_viva() {
    clear
    echo "Iniciando monitorización en vivo (presiona q para salir)..."
    sleep 2
    # Ejecuto top que es una herramienta de monitoreo en tiempo real
    top
}

# OPCIÓN 8: Visor de Registros
visor_registros() {
    while true; do
        clear
        echo "=== VISOR DE REGISTROS ==="
        echo "1. Últimos 20 eventos"
        echo "2. Monitorizar en tiempo real"
        echo "3. Volver"
        read -p "Elige opción: " opt
        
        case $opt in
            1)
                # Muestro los últimos 20 eventos del sistema
                journalctl -n 20 --no-pager
                pausa
                ;;
            2)
                # Sigo los eventos en tiempo real (Ctrl+C para salir)
                echo "Presiona Ctrl+C para salir"
                journalctl -f
                ;;
            3)
                return
                ;;
        esac
    done
}

# OPCIÓN 9: Gestión de Procesos
gestion_procesos() {
    while true; do
        clear
        echo "=== GESTIÓN DE PROCESOS ==="
        echo "1. Listar procesos"
        echo "2. Terminar un proceso"
        echo "3. Volver"
        read -p "Elige opción: " opt
        
        case $opt in
            1)
                # Muestro todos los procesos en ejecución
                ps aux | head -20
                pausa
                ;;
            2)
                read -p "PID del proceso a terminar: " pid
                # Compruebo que sea un número
                if [[ "$pid" =~ ^[0-9]+$ ]]; then
                    kill -9 "$pid"
                    echo "Proceso terminado"
                else
                    echo "El PID debe ser un número"
                fi
                pausa
                ;;
            3)
                return
                ;;
        esac
    done
}

# OPCIÓN 10: Monitorización de Procesos
monitorizacion_procesos() {
    clear
    read -p "Nombre del proceso a monitorizar: " proceso
    
    echo "Monitorizando $proceso (presiona Ctrl+C para salir)"
    
    # Actualizo la información cada 2 segundos
    while true; do
        clear
        echo "Proceso: $proceso - $(date)"
        # Busco el proceso y muestro su información
        ps aux | grep "[${proceso:0:1}]${proceso:1}"
        sleep 2
    done
}

# OPCIÓN 11: Programación de Backups
programacion_backups() {
    clear
    echo "=== PROGRAMACIÓN DE BACKUPS ==="
    
    read -p "Directorio de origen: " origen
    # Compruebo que el directorio exista
    if [[ ! -d "$origen" ]]; then
        echo "El directorio no existe"
        pausa
        return
    fi
    
    read -p "Directorio de destino: " destino
    # Compruebo que el directorio exista
    if [[ ! -d "$destino" ]]; then
        echo "El directorio no existe"
        pausa
        return
    fi
    
    echo "Frecuencia del backup:"
    echo "1. Diario (02:00)"
    echo "2. Semanal (lunes 02:00)"
    echo "3. Mensual (día 1 a las 02:00)"
    read -p "Elige: " freq
    
    # Creo el comando de backup con tar que comprime los archivos
    nombre="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    comando="tar -czf $destino/$nombre -C $(dirname $origen) $(basename $origen)"
    
    case $freq in
        1)
            # Diario: minuto 0, hora 2, todos los días
            echo "0 2 * * * $comando" | crontab -
            echo "Backup diario programado"
            ;;
        2)
            # Semanal: minuto 0, hora 2, lunes
            echo "0 2 * * 1 $comando" | crontab -
            echo "Backup semanal programado"
            ;;
        3)
            # Mensual: minuto 0, hora 2, día 1
            echo "0 2 1 * * $comando" | crontab -
            echo "Backup mensual programado"
            ;;
    esac
    
    pausa
}

# MENÚ PRINCIPAL con parámetros de línea de comandos
if [[ $# -gt 0 ]]; then
    # Si paso parámetros, ejecuto esa función directamente
    case "$1" in
        --info)
            diagnostico
            exit 0
            ;;
        --procesos)
            clear
            ps aux
            exit 0
            ;;
        --discos)
            administracion_discos
            exit 0
            ;;
        --help)
            echo "SysAdmin Toolbox"
            echo "Uso: $0 [OPCIÓN]"
            echo "Opciones:"
            echo "  --info      Muestra diagnóstico del sistema"
            echo "  --procesos  Lista los procesos"
            echo "  --discos    Muestra información de discos"
            echo "  --help      Muestra esta ayuda"
            exit 0
            ;;
    esac
else
    # Si no hay parámetros, muestro el menú interactivo
    while true; do
        clear
        echo "=== SYSADMIN TOOLBOX - MENÚ PRINCIPAL ==="
        echo ""
        echo "1.  Gestión de Usuarios y Grupos"
        echo "2.  Información de Cuentas"
        echo "3.  Gestión de Enlaces"
        echo "4.  Diagnóstico del Sistema"
        echo "5.  Gestión de Software"
        echo "6.  Administración de Discos"
        echo "7.  Monitorización en Vivo"
        echo "8.  Visor de Registros"
        echo "9.  Gestión de Procesos"
        echo "10. Monitorización de Procesos"
        echo "11. Programación de Backups"
        echo "0.  Salir"
        echo ""
        read -p "Elige una opción: " opcion
        
        case $opcion in
            1) gestion_usuarios ;;
            2) informacion_cuentas ;;
            3) gestion_enlaces ;;
            4) diagnostico ;;
            5) gestion_software ;;
            6) administracion_discos ;;
            7) monitorizacion_viva ;;
            8) visor_registros ;;
            9) gestion_procesos ;;
            10) monitorizacion_procesos ;;
            11) programacion_backups ;;
            0)
                echo "Saliendo..."
                exit 0
                ;;
            *)
                echo "Opción no válida"
                pausa
                ;;
        esac
    done
fi
