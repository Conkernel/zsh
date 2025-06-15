#!/bin/bash

# Este script verifica y obliga a que sea ejecutado directamente como el usuario root.
# No permitirá la ejecución si se usa 'sudo' por un usuario normal.

# Función para mostrar un mensaje de error y salir
exit_with_error() {
    echo "ERROR: $1" >&2
    echo "Este script debe ejecutarse DIRECTAMENTE como el usuario 'root'." >&2
    echo "Ejemplo: sudo su -c \"$(readlink -f "$0")\"" >&2
    echo "         o, si ya eres root: $(readlink -f "$0")" >&2
    exit 1
}

# 1. Comprobar si el UID es 0 (root)
# El UID (User ID) 0 siempre corresponde al usuario root.
if [ "$(id -u)" -ne 0 ]; then
    exit_with_error "No estás ejecutando el script como el usuario root."
fi

# 2. Comprobar si la variable SUDO_USER está configurada.
# La variable SUDO_USER se establece si el script se ejecuta a través de 'sudo'.
# Si está establecida y el UID es 0, significa que se usó 'sudo'.
if [ -n "$SUDO_USER" ]; then
    exit_with_error "Este script fue invocado usando 'sudo'. Por favor, ejecuta directamente como root."
fi

# 3. Si llegamos aquí, el usuario es root y no se usó sudo.
echo "¡Verificación de root exitosa! Estás ejecutando como el usuario root directamente."

sudo apt install zsh mlocate bat git curl xdg-utils ripgrep libnotify-bin     -y
[ -d /etc/zsh ] && mv /etc/zsh /etc/zsh.old 
mv zsh /etc/
[ -d /etc/bat ] && mv /etc/bat /etc/bat.old 
mv bat /etc/
curl -sS https://starship.rs/install.sh | sh
exit 0
