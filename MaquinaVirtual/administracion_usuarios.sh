#!/bin/bash

# Verifica si el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root." >&2
    exit 1
fi

# Función para crear un usuario
crear_usuario() {
    read -p "Ingrese el nombre de usuario: " usuario
    if id "$usuario" &>/dev/null; then
        echo "El usuario '$usuario' ya existe."
    else
        read -s -p "Ingrese la contraseña para '$usuario': " passwd
        echo
        useradd "$usuario"
        echo "$usuario:$passwd" | chpasswd
        echo "Usuario '$usuario' creado exitosamente."
    fi
}

# Función para eliminar un usuario
eliminar_usuario() {
    read -p "Ingrese el nombre de usuario a eliminar: " usuario
    if id "$usuario" &>/dev/null; then
        userdel -r "$usuario"
        echo "Usuario '$usuario' eliminado."
    else
        echo "El usuario '$usuario' no existe."
    fi
}

# Función para crear un grupo
crear_grupo() {
    read -p "Ingrese el nombre del grupo: " grupo
    if getent group "$grupo" > /dev/null; then
        echo "El grupo '$grupo' ya existe."
    else
        groupadd "$grupo"
        echo "Grupo '$grupo' creado exitosamente."
    fi
}

# Función para añadir usuario a un grupo
anadir_usuario_a_grupo() {
    read -p "Ingrese el nombre de usuario: " usuario
    if ! id "$usuario" &>/dev/null; then
        echo "El usuario '$usuario' no existe."
        return
    fi

    read -p "Ingrese el nombre del grupo: " grupo
    if ! getent group "$grupo" > /dev/null; then
        echo "El grupo '$grupo' no existe."
        return
    fi

    usermod -aG "$grupo" "$usuario"
    echo "Usuario '$usuario' añadido al grupo '$grupo'."
}

# Función para listar usuarios
listar_usuarios() {
    echo "Usuarios del sistema:"
    cut -d: -f1 /etc/passwd
}

# Función para listar grupos
listar_grupos() {
    echo "Grupos del sistema:"
    cut -d: -f1 /etc/group
}

# Función para listar usuarios de un grupo
listar_usuarios_de_grupo() {
    read -p "Ingrese el nombre del grupo: " grupo
    if getent group "$grupo" > /dev/null; then
        miembros=$(getent group "$grupo" | cut -d: -f4)
        echo "Usuarios en el grupo '$grupo': $miembros"
    else
        echo "El grupo '$grupo' no existe."
    fi
}

# Menú principal (solo una vez, sin bucle)
echo
echo "===== Administración de Usuarios ====="
echo "1) Crear usuario"
echo "2) Eliminar usuario"
echo "3) Crear grupo"
echo "4) Añadir usuario a grupo"
echo "5) Listar usuarios"
echo "6) Listar grupos"
echo "7) Listar usuarios de un grupo"
echo "0) Salir"
read -p "Seleccione una opción: " opcion
echo

case $opcion in
    1) crear_usuario ;;
    2) eliminar_usuario ;;
    3) crear_grupo ;;
    4) anadir_usuario_a_grupo ;;
    5) listar_usuarios ;;
    6) listar_grupos ;;
    7) listar_usuarios_de_grupo ;;
    0) echo "Saliendo..."; exit 0 ;;
    *) echo "Opción inválida." ;;
esac
