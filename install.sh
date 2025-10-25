set +x
# El UID (User ID) 0 siempre corresponde al usuario root.
if [ "$(id -u)" -ne 0 ]; then
    printf  "No estás ejecutando el script como el usuario root.\n\n"
    exit 1
fi


# ==============================================================================
# Detección del Sistema Operativo para la instalación de paquetes
# ==============================================================================
#!/bin/bash

# Función principal de detección
detectar_distro() {
    # 1. Método principal: Usar /etc/os-release (ESTÁNDAR MODERNO)
    if [ -f "/etc/os-release" ]; then
        # Carga las variables del archivo (NAME, ID, VERSION_ID, etc.)
        . /etc/os-release
        
        # Convierte el ID a minúsculas para comparaciones consistentes
        local ID_MINUSCULAS=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
        
        # Comprobación de distribuciones específicas
        case "$ID_MINUSCULAS" in
            # Familias Debian
            debian)
                PACKAGE_FOR_LS="eza"
                INSTALL="apt install -y"
                echo $ID_MINUSCULAS
                printf "Sistema detectado: Debian. Usando 'eza' para la instalación.\n\n"
                ;;
            ubuntu)
                echo "Distribución: Ubuntu"
                INSTALL="apt install -y"
                echo $ID_MINUSCULAS
                PACKAGE_FOR_LS="eza"
                printf "Sistema detectado: Ubuntu. Usando 'eza' para la instalación.\n\n"
                ;;
            rhel)
                PACKAGE_FOR_LS="eza"
                INSTALL="dnf install -y"                
                echo $ID_MINUSCULAS
                printf "Sistema detectado: RedHat. Usando 'eza' para la instalación.\n\n"
                ;;
            centos)
                echo $ID_MINUSCULAS
                INSTALL="dnf install -y"                
                ACKAGE_FOR_LS="eza"
                printf "Sistema detectado: Centos. Usando 'eza' para la instalación.\n\n"
                ;;

            arch | archarm)
                echo $ID_MINUSCULAS
                INSTALL="pacman -S --noconfirm"                
                PACKAGE_FOR_LS="eza"
                printf "Sistema detectado: Arch. Usando 'eza' para la instalación.\n\n"
                ;;
            
            # Si no coincide exactamente, muestra el nombre (ej. Mint, Pop!_OS)
            *)
                echo "La distro es $ID_MINUSCULAS"
                echo "Distribución (Base OS-RELEASE): $NAME $VERSION_ID"
                exit
                ;;
        esac
        
    # 2. Método de respaldo: Usar lsb_release (LEGADO)
    elif command -v lsb_release &> /dev/null; then
        echo "Distribución (Base LSB): $(lsb_release -ds)"
        exit

    # 3. Método de último recurso: Archivos específicos
    elif [ -f "/etc/redhat-release" ]; then
        # Atrapa versiones muy antiguas de RHEL/CentOS
        echo "Distribución (Base RedHat-release): $(cat /etc/redhat-release)"
        INSTALL="apt install"                

        
    else
        echo "Error: No se pudo detectar la distribución de Linux."
        exit
    fi
}

detectar_distro



# ==============================================================================
# Instalación de paquetes
# ==============================================================================
printf "Instalando paquetes esenciales...\n\n"
$INSTALL # Asegurarse de que los índices de paquetes estén actualizados

# Construyendo la lista de paquetes dinámicamente
APT_PACKAGES="zsh bat git curl xdg-utils ripgrep $PACKAGE_FOR_LS"

$INSTALL $APT_PACKAGES

# Verificar si la instalación de apt fue exitosa
if [ $? -ne 0 ]; then
    printf "ERROR: Falló la instalación de paquetes. Por favor, revisa los errores.\n\n" >&2
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




# Copiar configuración de Zsh
printf "Copiando configuración de Zsh...\n\n"
if [ -d /etc/zsh ]; then
    printf "Copia de seguridad de /etc/zsh en /etc/zsh.old... \n\n"
    if [ -d /etc/zsh.old ]; then
        printf "El directorio /etc/zsh.old ya existe. Eliminándolo para evitar conflictos.\n\n"
        sudo rm -rf /etc/zsh.old
    fi
    sudo cp -R /etc/zsh /etc/zsh.old
else
    mkdir -p /etc/zsh
fi

sudo tee -a /etc/zsh/zshrc << 'EOF'
ZSH_RC_USER="${HOME}/.config/zsh/.zshenv"
if [ -f "$ZSH_RC_USER" ]; then
    source "$ZSH_RC_USER"
fi
EOF

# Mover configuración de Bat
printf "Moviendo configuración de Bat...\n\n"
if [ -d /etc/bat ]; then
    printf "Copia de seguridad de /etc/bat en /etc/bat.old \n\n"
    mv -f /etc/bat /etc/bat.old
else
    printf "No existe configuración de bat previa.\n\n"
fi



exit 0
