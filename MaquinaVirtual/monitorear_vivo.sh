#!/bin/bash

# Script para monitorear el sistema
# Muestra opciones en un menú para ver info de discos y eventos

# Función que muestra el menú
menu() {
    echo ""
    echo "===== MONITOREO DEL SISTEMA ====="
    echo "1) Ver particiones (lsblk)"
    echo "2) Ver espacio en disco (df)"
    echo "3) Monitor en vivo (top)"
    echo "4) Últimos 20 eventos"
    echo "5) Eventos en vivo"
    echo "6) Salir"
    echo "=================================="
    read -p "Elige opción [1-6]: " opcion
}

# Muestra las particiones del sistema
ver_particiones() {
    echo ""
    echo "--- ESQUEMA DE PARTICIONES ---"
    # Uso lsblk para ver los discos y particiones
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
    echo ""
    read -p "Presiona Enter para volver..."
}

# Muestra el espacio disponible en discos
ver_espacio() {
    echo ""
    echo "--- ESPACIO EN DISCO ---"
    # Uso df -h para ver el espacio en formato legible
    df -h
    echo ""
    read -p "Presiona Enter para volver..."
}

# Inicia el monitor del sistema
monitor_vivo() {
    echo ""
    echo "Abriendo monitor en vivo (top)..."
    echo "Presiona 'q' para salir"
    echo ""
    sleep 2
    # Ejecuto top para ver procesos en tiempo real
    top
}

# Muestra los últimos 20 eventos del sistema
ver_eventos() {
    echo ""
    echo "--- ÚLTIMOS 20 EVENTOS ---"
    # Uso journalctl -n 20 para ver los últimos 20 eventos
    journalctl -n 20 --no-pager
    echo ""
    read -p "Presiona Enter para volver..."
}

# Monitorea los eventos en tiempo real
eventos_tiempo_real() {
    echo ""
    echo "Monitoreando eventos en tiempo real..."
    echo "Presiona Ctrl+C para salir"
    echo ""
    sleep 2
    # Uso journalctl -f para seguir los eventos en vivo
    journalctl -f --no-pager
}

# Bucle principal del script
while true; do
    menu

    # Según la opción, ejecuto una función
    case $opcion in
        1)
            ver_particiones
            ;;
        2)
            ver_espacio
            ;;
        3)
            monitor_vivo
            ;;
        4)
            ver_eventos
            ;;
        5)
            eventos_tiempo_real
            ;;
        6)
            echo ""
            echo "Saliendo del programa..."
            exit 0
            ;;
        *)
            echo "Opción no válida"
            read -p "Presiona Enter para continuar..."
            ;;
    esac
done