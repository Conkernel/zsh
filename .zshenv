
## Para copiar/pegar sin tener e cuenta los números de línea:
# seleccionar usando control + alt o usar :set invnumber. Tb se podría usar :set mouse=a pero es más incómodo


# Variables generales:
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/.cache"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/.zcachecompdump-${SHORT_HOST}-${ZSH_VERSION}"
# Compilation flags
export ARCHFLAGS="-arch x86_64"
# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
export VISUAL="nvim"
export HISTSIZE=10000
export SAVEHIST=10000
# Otras terms dan problemas de "echo" al usar algunos comandos. xterm-256color parece ir bien:
export TERM="xterm-256color"
#export DOTFILES="$HOME/.dotfiles"

# Manpages:
export MANPATH="/usr/share/man/:$MANPATH"
export MANPAGER='nvim +Man!'

# Coloreamos salida de Less:
export LESS='-R --use-color -Dd+r$Du+b'

# Locales
export LC_ALL="es_ES.UTF-8"
export LANG="es_ES.UTF-8"
export LANGUAGE="es_ES.UTF-8"
export LC_ADDRESS="es_ES.UTF-8"
export LC_COLLATE="es_ES.UTF-8"
export LC_CTYPE="es_ES.UTF-8"
export LC_IDENTIFICATION="es_ES.UTF-8"
export LC_MEASUREMENT="es_ES.UTF-8"
export LC_MESSAGES="es_ES.UTF-8"
export LC_MONETARY="es_ES.UTF-8"
export LC_NAME="es_ES.UTF-8"
export LC_NUMERIC="es_ES.UTF-8"
export LC_PAPER="es_ES.UTF-8"
export LC_TELEPHONE="es_ES.UTF-8"
export LC_TIME="es_ES.UTF-8"


# Por defecto, $PATH siempre contendrá lo mismo que haya en $path, pero se define en un array, que es más cómod y poderoso. Por eso no necesitamos definir $PATH aquí, sólo $path:
typeset -U path
path=(/opt/microsoft/msedge/ $path)
