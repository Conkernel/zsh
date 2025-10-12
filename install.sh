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

# ==============================================================================
# Detección del Sistema Operativo para la instalación de paquetes
# ==============================================================================
OS_NAME=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_NAME=$ID # ID es la variable que contiene el nombre de la distribución (debian, ubuntu, etc.)
fi

PACKAGE_FOR_LS="exa" # Valor por defecto

case "$OS_NAME" in
    debian)
        PACKAGE_FOR_LS="exa"
        echo "Sistema detectado: Debian. Usando 'exa' para la instalación."
        ;;
    ubuntu)
        PACKAGE_FOR_LS="eza"
        echo "Sistema detectado: Ubuntu. Usando 'eza' para la instalación."
        ;;
    *)
        echo "Sistema no reconocido como Debian o Ubuntu. Usando 'exa' como predeterminado."
        ;;
esac

# ==============================================================================
# Instalación de paquetes
# ==============================================================================
echo "Instalando paquetes esenciales..."
sudo apt update -y # Asegurarse de que los índices de paquetes estén actualizados

# Construyendo la lista de paquetes dinámicamente
APT_PACKAGES="zsh bat git curl xdg-utils ripgrep $PACKAGE_FOR_LS"

sudo apt install $APT_PACKAGES -y

# Verificar si la instalación de apt fue exitosa
if [ $? -ne 0 ]; then
    echo "ERROR: Falló la instalación de paquetes APT. Por favor, revisa los errores." >&2
    exit 1
fi

echo "Paquetes instalados correctamente."

# ==============================================================================
# Descarga y configuración de Zsh y Bat (de tu repositorio)
# ==============================================================================
echo "Descargando y configurando zsh y bat de tu repositorio..."
cd /tmp/ || exit_with_error "No se pudo cambiar al directorio /tmp/"

# Clonar el repositorio
if git clone https://github.com/conkernel/zsh; then
    echo "Repositorio conkernel/zsh clonado exitosamente."
else
    exit_with_error "Falló la clonación del repositorio conkernel/zsh."
fi

cd /tmp/zsh || exit_with_error "No se pudo cambiar al directorio /tmp/zsh/"

# Mover configuración de Zsh
echo "Moviendo configuración de Zsh..."
if [ -d /etc/zsh ]; then
    echo "Copia de seguridad de /etc/zsh en /etc/zsh.old"
    mv /etc/zsh /etc/zsh.old
fi
if mv zsh /etc/; then
    echo "Configuración de Zsh movida a /etc/zsh."
else
    exit_with_error "Falló el movimiento de la configuración de Zsh a /etc/."
fi

# Mover configuración de Bat
echo "Moviendo configuración de Bat..."
if [ -d /etc/bat ]; then
    echo "Copia de seguridad de /etc/bat en /etc/bat.old"
    mv /etc/bat /etc/bat.old
fi
if mv bat /etc/; then
    echo "Configuración de Bat movida a /etc/bat."
else
    exit_with_error "Falló el movimiento de la configuración de Bat a /etc/."
fi


# ==============================================================================
# Finalización
# ==============================================================================
echo "Configuración inicial completa. Iniciando Zsh..."
zsh

exit 0