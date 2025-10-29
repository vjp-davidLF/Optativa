#!/bin/bash

################################################################################
# SysAdmin Toolbox - Script de Administración de Sistemas
# Autor: Estudiante de 2º DAM/DAW
# Descripción: Herramienta centralizada para administración y monitorización
#              de sistemas Linux con menú interactivo
################################################################################

# SECCIÓN 1: VERIFICACIÓN DE PERMISOS
# Compruebo si el script se ejecuta como root porque muchas operaciones lo requieren
if [[ $EUID -ne 0 ]]; then
   echo "❌ Este script debe ejecutarse como root (con privilegios de superusuario)"
   echo "Intenta ejecutarlo con: sudo $0"
   exit 1
fi

################################################################################
# SECCIÓN 2: FUNCIONES DE UTILIDAD
################################################################################

# Función para pausar y mostrar un mensaje
pausa() {
    echo -e "\n📌 Presiona Enter para continuar..."
    read
}

# Función para limpiar pantalla y mostrar encabezado
mostrar_encabezado() {
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          🔧 SysAdmin Toolbox - Administración de Sistemas 🔧   ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
}

################################################################################
# SECCIÓN 3: GESTIÓN DE USUARIOS Y GRUPOS
################################################################################

gestion_usuarios_grupos() {
    # Esta función me permite crear/eliminar usuarios y gestionar grupos
    while true; do
        mostrar_encabezado
        echo "┌─ GESTIÓN DE USUARIOS Y GRUPOS ─────────────────────────────┐"
        echo "│ 1. Crear nuevo usuario                                      │"
        echo "│ 2. Eliminar usuario                                         │"
        echo "│ 3. Crear nuevo grupo                                        │"
        echo "│ 4. Asignar usuario a grupo                                  │"
        echo "│ 5. Volver al menú principal                                 │"
        echo "└─────────────────────────────────────────────────────────────┘"
        read -p "Selecciona una opción: " opcion
        
        case $opcion in
            1)
                # Crear usuario: pido el nombre y verifico que no exista
                read -p "Nombre del usuario a crear: " usuario
                if id "$usuario" &>/dev/null; then
                    echo "❌ El usuario $usuario ya existe"
                else
                    useradd -m -s /bin/bash "$usuario"
                    echo "✅ Usuario $usuario creado correctamente"
                fi
                pausa
                ;;
            2)
                # Eliminar usuario: verifico que exista primero
                read -p "Nombre del usuario a eliminar: " usuario
                if id "$usuario" &>/dev/null; then
                    userdel -r "$usuario"
                    echo "✅ Usuario $usuario eliminado correctamente"
                else
                    echo "❌ El usuario $usuario no existe"
                fi
                pausa
                ;;
            3)
                # Crear grupo: verifico que no exista antes
                read -p "Nombre del grupo a crear: " grupo
                if getent group "$grupo" &>/dev/null; then
                    echo "❌ El grupo $grupo ya existe"
                else
                    groupadd "$grupo"
                    echo "✅ Grupo $grupo creado correctamente"
                fi
                pausa
                ;;
            4)
                # Asignar usuario a grupo: verifico existencia de ambos
                read -p "Nombre del usuario: " usuario
                read -p "Nombre del grupo: " grupo
                if ! id "$usuario" &>/dev/null; then
                    echo "❌ El usuario $usuario no existe"
                elif ! getent group "$grupo" &>/dev/null; then
                    echo "❌ El grupo $grupo no existe"
                else
                    usermod -a -G "$grupo" "$usuario"
                    echo "✅ Usuario $usuario añadido al grupo $grupo"
                fi
                pausa
                ;;
            5)
                # Vuelvo al menú principal
                return
                ;;
            *)
                echo "❌ Opción no válida"
                pausa
                ;;
        esac
    done
}

################################################################################
# SECCIÓN 4: INFORMACIÓN DE CUENTAS
################################################################################

informacion_cuentas() {
    # Muestro los 10 primeros usuarios y grupos del sistema
    mostrar_encabezado
    echo "┌─ PRIMEROS 10 USUARIOS DEL SISTEMA ─────────────────────────────┐"
    head -n 10 /etc/passwd | cut -d: -f1,3,5 | column -t -s: -N "Usuario,UID,Nombre"
    echo "└─────────────────────────────────────────────────────────────────┘"
    
    echo ""
    echo "┌─ PRIMEROS 10 GRUPOS DEL SISTEMA ───────────────────────────────┐"
    head -n 10 /etc/group | cut -d: -f1,3 | column -t -s: -N "Grupo,GID"
    echo "└─────────────────────────────────────────────────────────────────┘"
    pausa
}

################################################################################
# SECCIÓN 5: GESTIÓN DE ENLACES
################################################################################

gestion_enlaces() {
    # Permito crear enlaces simbólicos y duros desde rutas del usuario
    while true; do
        mostrar_encabezado
        echo "┌─ GESTIÓN DE ENLACES ───────────────────────────────────────┐"
        echo "│ 1. Crear enlace simbólico                                   │"
        echo "│ 2. Crear enlace duro                                        │"
        echo "│ 3. Volver al menú principal                                 │"
        echo "└─────────────────────────────────────────────────────────────┘"
        read -p "Selecciona una opción: " opcion
        
        case $opcion in
            1)
                # Enlace simbólico: verifico que la ruta de origen existe
                read -p "Ruta del archivo/directorio original: " origen
                read -p "Ruta del enlace a crear: " destino
                if [[ -e "$origen" ]]; then
                    ln -s "$origen" "$destino"
                    echo "✅ Enlace simbólico creado correctamente"
                else
                    echo "❌ El archivo/directorio $origen no existe"
                fi
                pausa
                ;;
            2)
                # Enlace duro: solo funciona con archivos, verifico que exista
                read -p "Ruta del archivo original: " origen
                read -p "Ruta del enlace a crear: " destino
                if [[ -f "$origen" ]]; then
                    ln "$origen" "$destino"
                    echo "✅ Enlace duro creado correctamente"
                else
                    echo "❌ El archivo $origen no existe o no es un archivo regular"
                fi
                pausa
                ;;
            3)
                # Vuelvo al menú principal
                return
                ;;
            *)
                echo "❌ Opción no válida"
                pausa
                ;;
        esac
    done
}

################################################################################
# SECCIÓN 6: DIAGNÓSTICO DEL SISTEMA
################################################################################

diagnostico_sistema() {
    # Muestro información del hardware (CPU, RAM) y software (kernel, distribución)
    mostrar_encabezado
    echo "┌─ INFORMACIÓN DEL SISTEMA ──────────────────────────────────────┐"
    
    echo "🖥️  INFORMACIÓN DEL HARDWARE:"
    echo "   Procesador: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
    echo "   Núcleos: $(grep -c '^processor' /proc/cpuinfo)"
    echo "   RAM Total: $(free -h | grep Mem | awk '{print $2}')"
    echo "   RAM Disponible: $(free -h | grep Mem | awk '{print $7}')"
    
    echo ""
    echo "🔧 INFORMACIÓN DEL SOFTWARE:"
    echo "   Versión del Kernel: $(uname -r)"
    echo "   Sistema Operativo: $(lsb_release -d | cut -f2)"
    echo "   Hostname: $(hostname)"
    echo "   Fecha y Hora: $(date)"
    
    echo "└─────────────────────────────────────────────────────────────────┘"
    pausa
}

################################################################################
# SECCIÓN 7: GESTIÓN DE SOFTWARE
################################################################################

gestion_software() {
    # Permito listar paquetes instalados y buscar si uno específico está instalado
    while true; do
        mostrar_encabezado
        echo "┌─ GESTIÓN DE SOFTWARE ──────────────────────────────────────┐"
        echo "│ 1. Listar todos los paquetes instalados                     │"
        echo "│ 2. Buscar un paquete específico                             │"
        echo "│ 3. Filtrar paquetes por nombre                              │"
        echo "│ 4. Volver al menú principal                                 │"
        echo "└─────────────────────────────────────────────────────────────┘"
        read -p "Selecciona una opción: " opcion
        
        case $opcion in
            1)
                # Listo todos los paquetes (uso dpkg para sistemas Debian/Ubuntu)
                echo "Listando paquetes instalados..."
                dpkg -l | grep '^ii' | wc -l
                echo "Total de paquetes instalados"
                pausa
                ;;
            2)
                # Busco un paquete específico
                read -p "Nombre del paquete a buscar: " paquete
                if dpkg -l | grep -q "^ii.*$paquete"; then
                    echo "✅ El paquete $paquete está instalado"
                    dpkg -l | grep "^ii.*$paquete" | awk '{print $2, $3}'
                else
                    echo "❌ El paquete $paquete no está instalado"
                fi
                pausa
                ;;
            3)
                # Filtro paquetes por nombre (muestra solo los que coinciden)
                read -p "Filtro (parte del nombre del paquete): " filtro
                echo "Paquetes que coinciden con '$filtro':"
                dpkg -l | grep "^ii" | grep -i "$filtro" | awk '{print $2, $3}' | head -20
                pausa
                ;;
            4)
                # Vuelvo al menú principal
                return
                ;;
            *)
                echo "❌ Opción no válida"
                pausa
                ;;
        esac
    done
}

################################################################################
# SECCIÓN 8: ADMINISTRACIÓN DE DISCOS
################################################################################

administracion_discos() {
    # Muestro esquema de particiones y uso de espacio en disco
    mostrar_encabezado
    echo "┌─ ESQUEMA DE PARTICIONES Y VOLÚMENES ───────────────────────────┐"
    lsblk
    echo "└─────────────────────────────────────────────────────────────────┘"
    
    echo ""
    echo "┌─ USO DE ESPACIO EN DISCO ───────────────────────────────────────┐"
    df -h
    echo "└─────────────────────────────────────────────────────────────────┘"
    pausa
}

################################################################################
# SECCIÓN 9: MONITORIZACIÓN EN VIVO
################################################################################

monitorizacion_viva() {
    # Ejecuto top para monitorización en tiempo real
    mostrar_encabezado
    echo "Iniciando top para monitorización en vivo..."
    echo "Presiona 'q' para salir de top"
    pausa
    top
}

################################################################################
# SECCIÓN 10: VISOR DE REGISTROS
################################################################################

visor_registros() {
    # Muestro últimos eventos del sistema con journalctl
    while true; do
        mostrar_encabezado
        echo "┌─ VISOR DE REGISTROS DEL SISTEMA ───────────────────────────┐"
        echo "│ 1. Ver últimos 20 eventos del sistema                       │"
        echo "│ 2. Monitorizar registros en tiempo real                     │"
        echo "│ 3. Ver registros de hoy                                     │"
        echo "│ 4. Volver al menú principal                                 │"
        echo "└─────────────────────────────────────────────────────────────┘"
        read -p "Selecciona una opción: " opcion
        
        case $opcion in
            1)
                # Últimos 20 eventos del sistema
                echo "Últimos 20 eventos:"
                journalctl -n 20 --no-pager
                pausa
                ;;
            2)
                # Monitorizar en tiempo real (presiona Ctrl+C para salir)
                echo "Monitorizando registros en tiempo real..."
                echo "Presiona Ctrl+C para salir"
                journalctl -f
                ;;
            3)
                # Registros de hoy
                echo "Registros de hoy:"
                journalctl --since today --no-pager
                pausa
                ;;
            4)
                # Vuelvo al menú principal
                return
                ;;
            *)
                echo "❌ Opción no válida"
                pausa
                ;;
        esac
    done
}

################################################################################
# SECCIÓN 11: GESTIÓN DE PROCESOS
################################################################################

gestion_procesos() {
    # Listo procesos en ejecución y permito terminar alguno por su PID
    while true; do
        mostrar_encabezado
        echo "┌─ GESTIÓN DE PROCESOS ──────────────────────────────────────┐"
        echo "│ 1. Listar todos los procesos en ejecución                   │"
        echo "│ 2. Terminar un proceso por PID                              │"
        echo "│ 3. Volver al menú principal                                 │"
        echo "└─────────────────────────────────────────────────────────────┘"
        read -p "Selecciona una opción: " opcion
        
        case $opcion in
            1)
                # Listo procesos de forma legible
                echo "Listando procesos en ejecución (primeros 30):"
                ps aux | head -31
                pausa
                ;;
            2)
                # Pido el PID del proceso a terminar
                read -p "Ingresa el PID del proceso a terminar: " pid
                # Verifico que el PID sea un número válido
                if [[ "$pid" =~ ^[0-9]+$ ]]; then
                    if kill -0 "$pid" 2>/dev/null; then
                        kill -9 "$pid"
                        echo "✅ Proceso $pid terminado"
                    else
                        echo "❌ El proceso con PID $pid no existe"
                    fi
                else
                    echo "❌ El PID debe ser un número"
                fi
                pausa
                ;;
            3)
                # Vuelvo al menú principal
                return
                ;;
            *)
                echo "❌ Opción no válida"
                pausa
                ;;
        esac
    done
}

################################################################################
# SECCIÓN 12: MONITORIZACIÓN DE PROCESOS
################################################################################

monitorizacion_procesos() {
    # Sigo un proceso específico por su nombre, actualizando su estado
    mostrar_encabezado
    read -p "Nombre del proceso a monitorizar: " nombre_proceso
    
    echo "Monitorizando proceso: $nombre_proceso"
    echo "Presiona Ctrl+C para detener"
    echo ""
    
    # Actualizo el estado del proceso cada 2 segundos
    while true; do
        clear
        echo "Monitorizando: $nombre_proceso"
        echo "Actualizado: $(date '+%H:%M:%S')"
        echo "─────────────────────────────────────────────────────────"
        ps aux | grep "[${nombre_proceso:0:1}]${nombre_proceso:1}" || echo "Proceso no encontrado"
        sleep 2
    done
}

################################################################################
# SECCIÓN 13: PROGRAMACIÓN DE BACKUPS (CRON)
################################################################################

programacion_backups() {
    # Creo tareas de backup automatizadas en cron
    mostrar_encabezado
    echo "╔═ PROGRAMACIÓN DE BACKUPS ══════════════════════════════════════╗"
    
    # Pido el directorio de origen
    read -p "Directorio de origen para el backup: " directorio_origen
    if [[ ! -d "$directorio_origen" ]]; then
        echo "❌ El directorio $directorio_origen no existe"
        pausa
        return
    fi
    
    # Pido el directorio de destino
    read -p "Directorio de destino para el backup: " directorio_destino
    if [[ ! -d "$directorio_destino" ]]; then
        echo "❌ El directorio $directorio_destino no existe"
        pausa
        return
    fi
    
    # Muestro opciones de frecuencia
    echo "Selecciona la frecuencia del backup:"
    echo "1. Diario (cada día a las 02:00)"
    echo "2. Semanal (cada lunes a las 02:00)"
    echo "3. Mensual (primer día del mes a las 02:00)"
    read -p "Opción: " frecuencia
    
    # Creo el nombre del archivo de backup
    local nombre_backup="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    local comando_tar="tar -czf $directorio_destino/$nombre_backup -C $(dirname $directorio_origen) $(basename $directorio_origen)"
    
    # Añado la tarea según la frecuencia seleccionada
    case $frecuencia in
        1)
            # Diario: minuto 0, hora 2, cualquier día del mes
            echo "0 2 * * * $comando_tar" | crontab -
            echo "✅ Backup diario programado para las 02:00"
            ;;
        2)
            # Semanal: minuto 0, hora 2, cualquier día del mes, lunes (1)
            echo "0 2 * * 1 $comando_tar" | crontab -
            echo "✅ Backup semanal programado para los lunes a las 02:00"
            ;;
        3)
            # Mensual: minuto 0, hora 2, primer día del mes
            echo "0 2 1 * * $comando_tar" | crontab -
            echo "✅ Backup mensual programado para el 1º de cada mes a las 02:00"
            ;;
        *)
            echo "❌ Opción no válida"
            ;;
    esac
    
    echo "Origen: $directorio_origen"
    echo "Destino: $directorio_destino"
    echo "Comando: $comando_tar"
    pausa
}

################################################################################
# SECCIÓN 14: MENÚ PRINCIPAL
################################################################################

menu_principal() {
    # Muestro el menú principal con todas las opciones disponibles
    while true; do
        mostrar_encabezado
        echo "┌─ MENÚ PRINCIPAL ───────────────────────────────────────────┐"
        echo "│  1. Gestión de Usuarios y Grupos                            │"
        echo "│  2. Información de Cuentas                                  │"
        echo "│  3. Gestión de Enlaces                                      │"
        echo "│  4. Diagnóstico del Sistema                                 │"
        echo "│  5. Gestión de Software                                     │"
        echo "│  6. Administración de Discos                                │"
        echo "│  7. Monitorización en Vivo                                  │"
        echo "│  8. Visor de Registros                                      │"
        echo "│  9. Gestión de Procesos                                     │"
        echo "│ 10. Monitorización de Procesos                              │"
        echo "│ 11. Programación de Backups (Cron)                          │"
        echo "│  0. Salir                                                   │"
        echo "└─────────────────────────────────────────────────────────────┘"
        read -p "Selecciona una opción: " opcion
        
        case $opcion in
            1) gestion_usuarios_grupos ;;
            2) informacion_cuentas ;;
            3) gestion_enlaces ;;
            4) diagnostico_sistema ;;
            5) gestion_software ;;
            6) administracion_discos ;;
            7) monitorizacion_viva ;;
            8) visor_registros ;;
            9) gestion_procesos ;;
            10) monitorizacion_procesos ;;
            11) programacion_backups ;;
            0)
                echo "👋 ¡Hasta luego!"
                exit 0
                ;;
            *)
                echo "❌ Opción no válida. Intenta de nuevo."
                pausa
                ;;
        esac
    done
}

################################################################################
# SECCIÓN 15: MANEJO DE PARÁMETROS DE LÍNEA DE COMANDOS
################################################################################

# Compruebo si se pasaron parámetros al script
if [[ $# -gt 0 ]]; then
    case "$1" in
        --info)
            # Ejecuto diagnóstico del sistema y salgo sin mostrar el menú
            diagnostico_sistema
            exit 0
            ;;
        --procesos)
            # Listo procesos en ejecución y salgo
            mostrar_encabezado
            ps aux
            exit 0
            ;;
        --discos)
            # Muestro información de discos y salgo
            administracion_discos
            exit 0
            ;;
        --help)
            # Muestro ayuda
            echo "SysAdmin Toolbox - Herramienta de Administración de Sistemas"
            echo ""
            echo "Uso: $0 [OPCIÓN]"
            echo ""
            echo "Opciones:"
            echo "  (sin parámetros)  Ejecuta el menú interactivo"
            echo "  --info            Muestra información del sistema"
            echo "  --procesos        Lista todos los procesos"
            echo "  --discos          Muestra información de discos"
            echo "  --help            Muestra este mensaje de ayuda"
            exit 0
            ;;
        *)
            echo "❌ Parámetro no reconocido: $1"
            echo "Intenta con: $0 --help"
            exit 1
            ;;
    esac
else
    # Si no hay parámetros, ejecuto el menú principal interactivo
    menu_principal
fi
