#!/bin/bash
echo "Introduce el nombre de usuario:"
read usuario

# Comprueba si el usuario ya existe
if id "$usuario" &>/dev/null; then
    echo "El usuario '$usuario' ya existe. Abortando."
    exit 1
fi

# Solicita la contraseña
read -s -p "Introduce la contraseña para '$usuario': " password
echo

# Crea el usuario y asigna la contraseña
sudo useradd "$usuario"
echo "$usuario:$password" | sudo chpasswd

echo "Usuario '$usuario' creado y contraseña asignada."

echo "Introduce el nombre de usuario a eliminar:"
read usuario

# Comprueba si el usuario existe
if ! id "$usuario" &>/dev/null; then
    echo "El usuario '$usuario' no existe. Abortando."
    exit 1
fi

# Elimina el usuario y su directorio home
sudo userdel -r "$usuario"

echo "Usuario '$usuario' eliminado."

echo "Introduce el nombre del grupo a crear:"
read grupo

# Comprueba si el grupo ya existe
if grep -q "^$grupo:" /etc/group; then
    echo "El grupo '$grupo' ya existe. Abortando."
    exit 1
fi

# Crea el grupo
sudo groupadd "$grupo"
echo "Grupo '$grupo' creado."

echo "Introduce el nombre del grupo a eliminar:"
read grupo

# Comprueba si el grupo existe
if ! grep -q "^$grupo:" /etc/group; then
    echo "El grupo '$grupo' no existe. Abortando."
    exit 1
fi

# Elimina el grupo
sudo groupdel "$grupo"

echo "Grupo '$grupo' eliminado."




