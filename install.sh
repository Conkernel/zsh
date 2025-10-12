# El UID (User ID) 0 siempre corresponde al usuario root.
if [ "$(id -u)" -ne 0 ]; then
    printf  "No estás ejecutando el script como el usuario root.\n\n"
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
        printf "Sistema detectado: Debian. Usando 'exa' para la instalación.\n\n"
        ;;
    ubuntu)
        PACKAGE_FOR_LS="eza"
        printf "Sistema detectado: Ubuntu. Usando 'eza' para la instalación.\n\n"
        ;;
    *)
        printf "Sistema no reconocido como Debian o Ubuntu. Usando 'exa' como predeterminado.\n\n"
        ;;
esac

# ==============================================================================
# Instalación de paquetes
# ==============================================================================
printf "Instalando paquetes esenciales...\n\n"
sudo apt update -y # Asegurarse de que los índices de paquetes estén actualizados

# Construyendo la lista de paquetes dinámicamente
APT_PACKAGES="zsh bat git curl xdg-utils ripgrep $PACKAGE_FOR_LS"

sudo apt install $APT_PACKAGES -y

# Verificar si la instalación de apt fue exitosa
if [ $? -ne 0 ]; then
    printf "ERROR: Falló la instalación de paquetes APT. Por favor, revisa los errores.\n\n" >&2
    exit 1
fi

printf "Paquetes instalados correctamente.\n\n"

# ==============================================================================
# Descarga y configuración de Zsh y Bat (de tu repositorio)
# ==============================================================================
printf "Descargando y configurando zsh y bat de tu repositorio...\n\n"
cd /tmp/ || printf "No se pudo cambiar al directorio /tmp/ \n\n"

# Clonar el repositorio
git clone https://github.com/conkernel/zsh
if [ $? -ne 0 ]; then
    printf "ERROR: Falló la descarga del repo git.\n\n" >&2
else
    printf "Repositorio conkernel/zsh clonado exitosamente.\n\n"
fi

cd /tmp/zsh || printf "No se pudo cambiar al directorio /tmp/zsh/ \n\n"

# Mover configuración de Zsh
printf "Moviendo configuración de Zsh...\n\n"
if [ -d /etc/zsh ]; then
    printf "Copia de seguridad de /etc/zsh en /etc/zsh.old... \n\n"
    mv /etc/zsh /etc/zsh.old
fi

if [ -d /etc/zsh.old ]; then
    printf "Configuración de Zsh movida a /etc/zsh.\n\n"
else
    printf "Falló el movimiento de la configuración de Zsh a /etc/.\n\n"
fi

# Mover configuración de Bat
printf "Moviendo configuración de Bat...\n\n"
if [ -d /etc/bat ]; then
    printf "Copia de seguridad de /etc/bat en /etc/bat.old \n\n"
    mv -f /etc/bat /etc/bat.old
else
    printf "No existe configuración de bat previa.\n\n"
fi





sudo tee -a /etc/zsh/zshrc << EOF
ZSH_RC_USER="${HOME}/.config/zsh/.zshenv"
if [ -f "$ZSH_RC_USER" ]; then
    # Carga (source) el archivo de configuración local
    source "$ZSH_RC_USER"
fi
EOF




# ==============================================================================
# Finalización
# ==============================================================================
printf "Configuración inicial completa. Iniciando Zsh... \n\n"
zsh

exit 0