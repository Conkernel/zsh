#!/bin/bash

# set -x

# --- 1. VERIFICACIÓN DE PRIVILEGIOS (EUID) ---

# EUID (Effective User ID) es 0 si el script se ejecuta como root (o con sudo).
if [ "$EUID" -ne 0 ]; then
    # Si no es root, muestra un error y sale
    echo "🚨 ERROR: Este script debe ejecutarse con privilegios de root (sudo)."
    echo "Por favor, inténtalo de nuevo con: sudo $0"
    exit 1
fi

# --- 2. VERIFICACIÓN DE USUARIO Y EJECUCIÓN ---

# Si llegamos aquí, sabemos que estamos usando sudo/root.

# El usuario original se almacena en la variable 'SUDO_USER'
# (si fue llamado con sudo). Si fue llamado directamente como root,
# SUDO_USER estará vacío.
if [ -n "$SUDO_USER" ]; then
    USUARIO_EJECUTOR="$SUDO_USER"
else
    # Si SUDO_USER está vacío, obtenemos el nombre del usuario root
    USUARIO_EJECUTOR=$(whoami) 
fi

printf "✅ Verificación de privilegios superada.\n\n"
printf "Usuario original que lanzó el script: $USUARIO_EJECUTOR\n\n"



if [ "$USUARIO_EJECUTOR" == "root" ]; then
    HOMEDIR="/root"
else    
    # Método más robusto: usar getent passwd o ~ si estamos en el entorno del usuario
    # Pero para este caso simple, la ruta /home/ funciona si el usuario no es root.
    HOMEDIR="/home/$USUARIO_EJECUTOR"
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
        INSTALL="yum install -y"                

        
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

# Construyendo la lista de paquetes dinámicamente
APT_PACKAGES="zsh bat git curl ripgrep $PACKAGE_FOR_LS"

$INSTALL $APT_PACKAGES

# Verificar si la instalación de apt fue exitosa
if [ $? -ne 0 ]; then
    printf "ERROR: Falló la instalación de paquetes. Por favor, revisa los errores.\n\n" >&2
    exit 1
fi

printf "Paquetes instalados correctamente.\n\n"



# Backup previo de /etc/zsh
printf "Haciendo backup de la configuración de Zsh...\n\n"
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

# 

sudo tee -a /etc/zsh/zshrc << 'EOF'
ZSH_ENV_USER="${HOME}/.config/zsh/.zshenv"
if [ -f "$ZSH_ENV_USER" ]; then
    source "$ZSH_ENV_USER"
fi
EOF

# Crear ruta para fzf
printf "Creando ruta local de fzf \n\n"
sudo mkdir -p $HOMEDIR/.fzf



# Mover configuración de Bat
printf "Moviendo configuración de Bat...\n\n"
if [ -d /etc/bat ]; then
    printf "Copia de seguridad de /etc/bat en /etc/bat.old \n\n"
    sudo mv -f /etc/bat /etc/bat.old
else
    printf "No existe configuración de bat previa.\n\n"
fi




# Backup de zsh previo
printf "Hacemos backup de la configuración previa de zsh del usuario...\n\n"
if [ -d $HOMEDIR/.fzf.old ]; then
    rm -rf $HOMEDIR/.config/zsh.old
    sudo mv $HOMEDIR/.config/zsh $HOMEDIR/.config/zsh.old
fi

printf "Creando home para zsh...\n\n"
sudo mkdir $HOMEDIR/.config/zsh -p

echo "" > $HOMEDIR/.zshrc


git clone https://github.com/Conkernel/zsh.git $HOMEDIR/.config/zsh
rm -rf $HOMEDIR/powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOMEDIR/powerlevel10k
rm $HOMEDIR/powerlevel10k/.git -rf
rm $HOMEDIR/.fzf/.git -rf

# Permisos
printf "Adecuando permisos para $USUARIO_EJECUTOR \n\n"


echo "usuario: $USUARIO_EJECUTOR y ruta: $HOMEDIR"

read -p "Presiona Enter para continuar..."

sudo chown -R $USUARIO_EJECUTOR:$USUARIO_EJECUTOR $HOMEDIR/


# exec su - "$USUARIO_EJECUTOR" -c "/bin/zsh"

exit 0

