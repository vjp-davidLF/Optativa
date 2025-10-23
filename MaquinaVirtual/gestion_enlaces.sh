#!/bin/bash

# Script de Gestión de Enlaces, Información del Sistema y Paquetes
# Autor: yo mismo
# Descripción: Script con menú para crear enlaces, ver info del sistema y gestionar paquetes

# Función para crear enlace duro
crear_enlace_duro() {
    # Pido que ingrese la ruta del fichero origen
    read -p "Ingrese la ruta del fichero destino: " fichero
    
    # Compruebo si el fichero existe antes de crear el enlace
    if [ ! -e "$fichero" ]; then
        echo "Error: El fichero '$fichero' no existe."
        return
    fi

    # Pido el nombre que quiero dar al enlace duro
    read -p "Ingrese el nombre del enlace: " enlace
    
    # Intento crear el enlace duro con ln y muestro un mensaje de éxito o error
    if ln "$fichero" "$enlace"; then
        echo "Enlace duro '$enlace' creado exitosamente apuntando a '$fichero'."
    else
        echo "Error al crear el enlace duro."
    fi
}

# Función para crear enlace simbólico
crear_enlace_simbolico() {
    # Pido que ingrese la ruta del fichero origen
    read -p "Ingrese la ruta del fichero destino: " fichero
    
    # Compruebo si el fichero existe antes de crear el enlace
    if [ ! -e "$fichero" ]; then
        echo "Error: El fichero '$fichero' no existe."
        return
    fi

    # Pido el nombre que quiero dar al enlace simbólico
    read -p "Ingrese el nombre del enlace simbólico: " enlace
    
    # Creo el enlace simbólico con ln -s (este apunta al archivo sin copiar contenido)
    if ln -s "$fichero" "$enlace"; then
        echo "Enlace simbólico '$enlace' creado exitosamente apuntando a '$fichero'."
    else
        echo "Error al crear el enlace simbólico."
    fi
}

# Función para mostrar información del sistema
info_sistema() {
    # Muestro un separador para que sea más legible
    echo
    echo "===== Información del Sistema ====="
    echo
    
    # Uso lscpu para obtener información del procesador
    echo "--- Información de CPU (lscpu) ---"
    # Filtro solo las líneas que me interesan: modelo, número de CPUs y velocidad
    lscpu | grep -E "Model name:|CPU\(s\):|CPU max MHz:|CPU min MHz:" | while IFS=: read -r key value; do
        echo "$key:$value"
    done
    echo
    
    # Uso free -h para ver el uso de memoria RAM en formato legible (GB, MB, etc)
    echo "--- Uso de Memoria RAM (free) ---"
    free -h
    echo
}

# Función para gestionar paquetes
gestionar_paquetes() {
    # Muestro un submenú para elegir qué hacer con los paquetes
    echo
    echo "===== Gestor de Paquetes ====="
    echo "1) Comprobar si un paquete está instalado"
    echo "2) Listar todos los paquetes instalados"
    echo "0) Volver al menú principal"
    read -p "Seleccione una opción: " opcion_paquetes
    echo

    # Según la opción elegida, ejecuto una u otra acción
    case $opcion_paquetes in
        1)
            # Opción 1: Comprobar si un paquete específico está instalado
            read -p "Ingrese el nombre del paquete: " paquete
            
            # Uso dpkg -s para buscar el paquete (silenciosamente con 2>/dev/null)
            if dpkg -s "$paquete" &>/dev/null; then
                echo "El paquete '$paquete' está instalado."
                echo
                # Muestro detalles del paquete: nombre, versión y estado
                dpkg -s "$paquete" | grep -E "^Package:|^Version:|^Status:"
            else
                echo "El paquete '$paquete' NO está instalado."
            fi
            ;;
        2)
            # Opción 2: Listar todos los paquetes instalados
            echo "Paquetes instalados:"
            echo
            # Uso dpkg -l para listar (omito las primeras 5 líneas con tail)
            # y solo muestro nombre del paquete y versión con awk
            dpkg -l | tail -n +6 | awk '{print $2, $3}'
            ;;
        0)
            # Opción 0: Volver al menú principal sin hacer nada
            return
            ;;
        *)
            # Si introduce una opción inválida, le muestro error
            echo "Opción inválida."
            ;;
    esac
    echo
}

# Menú principal
while true; do
    # Muestro el menú con todas las opciones disponibles
    echo
    echo "===== Gestión de Enlaces y Sistema ====="
    echo "1) Crear enlace duro"
    echo "2) Crear enlace simbólico"
    echo "3) Mostrar información del sistema"
    echo "4) Gestionar paquetes"
    echo "---"
    echo "0) Salir"
    read -p "Seleccione una opción: " opcion
    echo

    # Según la opción, ejecuto la función correspondiente
    case $opcion in
        1) crear_enlace_duro ;;
        2) crear_enlace_simbolico ;;
        3) info_sistema ;;
        4) gestionar_paquetes ;;
        0) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción inválida." ;;
    esac
done


