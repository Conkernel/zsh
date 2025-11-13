
export TERM=xterm-256color

source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# Primero habilitamos las opciones con las que queremos que inicie zsh:
source $ZDOTDIR/.zoptions

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi



## RUN_HELP ##
export HELPDIR="/usr/share/zsh/$(zsh --version | cut -d' ' -f2)/help" # directory for run-help function to find docs
unalias run-help 2>/dev/null       # don't display err if already done
autoload -Uz run-help              # load the function
alias help=run-help                #ahora podremos usar help, o run-help 'comando' para ver su ayuda.
autoload run-help-svn
autoload run-help-svk
autoload run-help-git
autoload run-help-ip
autoload run-help-openssl
autoload run-help-p4
autoload run-help-sudo
# Pulsamos "comando" + F1 para mostrar ayuda sobre ese comando, gracias a la ayuda de la función run-help:
bindkey '^[OP' run-help # con el comando escrito y pulsando F1 se muestra ayuda.
###############


# Definimos contenedor para los plugins:
export ZSH_PLUGINS="$HOME/.config/zsh/plugins"

# fpath es solo para funciones:
fpath=($ZSH_PLUGINS/zsh-completions/src $fpath)

# Autoload all shell functions from all directories in $fpath (following symlinks) that have the executable bit on (the executable bit is not necessary, but gives you an easy way to stop the  autoloading of a particular shell function). $fpath should not be empty for this to work.
for func in $^fpath/*(N-.x:t); autoload $func


### History ###
HISTFILE=~/.config/zsh/.zhistory # Rutadel fichero de historial
HISTSIZE=1024 # Tamaño del fichero
SAVEHIST=5000 # Número de comandos almacenados en el HISTFILE  
###############



### BINDKEYS ###
#bindkey -e #funcionamiento tipo emacs
#bindkey '^H' backward-delete-char
#bindkey '^?' backward-kill-word
# Las dos de arriba funcionan bien con mobaxterm/zsh, pero mal con mobaxterm/bash

bindkey '^[[3~'   delete-char # borra caracter actual

# --- FIX teclas Home y End en Tabby ---
# Desactivar modo de cursor de aplicación
function zle-line-init() {
  echoti rmkx        # Disable application cursor mode
}
function zle-line-finish() {
  echoti smkx        # Re-enable if needed
}
zle -N zle-line-init
zle -N zle-line-finish

# Mapear secuencias estándar de teclas
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^R' history-incremental-search-backward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
#tecla arriba:
bindkey '^[[A'    up-line-or-beginning-search
#tecla abajo:
bindkey '^[[B'    down-line-or-beginning-search
# tecla av pag
bindkey '^[[6~'   up-line-or-beginning-search
# tecla re pag
bindkey '^[[5~'   down-line-or-beginning-search
bindkey '^[[Z'    undo                               # shift + tab undo last action
# ejecutar comando con sudo. Revisar el keybinding:
run-with-sudo () { LBUFFER="sudo $LBUFFER" }
zle -N run-with-sudo
bindkey '^[^[' run-with-sudo


### Funciones
# Busca los ficheros más grandes de un directorio
function grandes () {
    du -h -x -s -- * 2> /dev/null | sort -r -h | head -20;
}




#Muestra el branch de git actual. Se escribe a mano ya que no existe ene l plugin git.zsh
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
#Muestra dos [] en las que se detalla el estado de los repos .git:
parse_git_dirty() {
  STATUS="$(LANGUAGE=en git status 2> /dev/null)"
  if [[ $? -ne 0 ]]; then printf ""; return; else printf " ["; fi
  if echo "${STATUS}" | grep -c "renamed:"         &> /dev/null; then printf " >"; else printf ""; fi
  if echo "${STATUS}" | grep -c "branch is ahead:" &> /dev/null; then printf " !"; else printf ""; fi
  if echo "${STATUS}" | grep -c "new file::"       &> /dev/null; then printf " +"; else printf ""; fi
  if echo "${STATUS}" | grep -c "Untracked files:" &> /dev/null; then printf " ?"; else printf ""; fi
  if echo "${STATUS}" | grep -c "modified:"        &> /dev/null; then printf " *"; else printf ""; fi
  if echo "${STATUS}" | grep -c "deleted:"         &> /dev/null; then printf " -"; else printf ""; fi
  printf " ]"
}

#Vigilante:
#muestra si alguien inicia sesión. Si alguien incia, se mostrará después de ejecutar cualquier comando, y no de forma automática:
watch=(notme)         # watch for everybody but me
LOGCHECK=30           # check every 60 sec for login/logout activity
WATCHFMT="%n %a %l desde %m el $(date +"%A %d de %B de %Y a las %T")"



#este código define un alias para abrir archivos HTML y HTM usando un navegador web. Cuando intenta abrir un archivo de este tipo, se activa la función pick-web-browseralias, que presumiblemente se encarga de seleccionar y abrir el navegador adecuado:
autoload -U pick-web-browser
alias -s {html,htm}=pick-web-browser


# Sistema de autocompletado de zsh:
autoload -Uz compinit
# (-d) en caso de que lo queramos cargar, eliminando previamente la caché existente en el fichero:
compinit # -d ~/.config/zsh/.zcache

# Load colors so we can access $fg and more.
autoload -U colors
colors


# Hacer que los nuevos ejecutables sean añadidos al completion sin tener que reiniciar la terminal:
zstyle ':completion:*' rehash true
#muestra un menu al utilizar el automcpletado con tab (parece no funcionar bien):
zstyle ':completion:*' menu select
# }}}
# {{{ Fancy menu selection when there's ambiguity
#Para pruebas:
zstyle ':completion:*' menu yes select interactive
zstyle ':completion:*' menu yes=long select=long interactive
zstyle ':completion:*' menu yes=10 select=10 interactive
#colores en completion
zstyle ':completion:*' list-colors "$LS_COLORS"
#When you match files using the completion, they will be ordered by date of modification
zstyle ':completion:*' file-sort modification
# cache de completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.config/zsh/.zcache
# fichero particular para los completados de zsh:
#zstyle :compinstall filename '~/.config/zsh/.zshrc'
#No consigo que funcione, o no sé usarlo
#zstyle :completion:ls color red
#zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#zstyle ':completion:*' completer _complete _match _approximate
#zstyle ':completion:*:match:*' original only
#zstyle ':completion:*:approximate:*' max-errors 1 numeric
#Ignore completion functions for commands you don’t have:
#zstyle ':completion:*:functions' ignored-patterns '_*'
#Completing process IDs with menu selection:
#zstyle ':completion:*:*:kill:*' menu yes select
#zstyle ':completion:*:kill:*'   force-list always


#añadimos el plugin de git para poder usar sus funciones (da errores.no encuentra compdef... y es muy lento con el promt):
#source ~/.config/zsh/plugins/git/git.plugin.zsh
#añadimos el plugin de autosugestions:
source $ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh
#syntax-highligfhting. Siempre debe ir al final del zshrc:
source $ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Para usar junto con fzf:
source $ZSH_PLUGINS/fzf-zsh-plugin/fzf-zsh-plugin.plugin.zsh



#PROMPTS:

#Dependiendo del tipo de usuario que seam mostrará $ o #:
if [[ $EUID == 0 ]]; then
PROMPT='%{$fg[blue]%} %{$fg[blue]%}%n%{$fg[red]%}@%{$fg[blue]%}%m# %F{015}%~ %F{006}%(?..%{$fg[red]%})%b '
else
PROMPT='%{$fg[blue]%} %{$fg[blue]%}%n%{$fg[red]%}@%{$fg[blue]%}%m$ %F{015}%~ %F{006}%(?..%{$fg[red]%})%b '
fi
#hacemos uso de algunas funciones que nos da git.zsh y las mostramos en el prompt derecho,además de la hora:
RPROMPT='%B%F{006}$(parse_git_branch)%F{003}$(parse_git_dirty) %B%F{015}%T %D{%A} %D{%d}/%D{%m}/%D{%Y}'
#dejamos un espacio en blanco entre cada comando:
precmd() { print ""} 

# Más SOURCES:
source $ZDOTDIR/.zaliases

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh


