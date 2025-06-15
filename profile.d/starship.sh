#!/bin/sh
# Inicializar Starship si el binario existe y la shell es interactiva
if [ -n "$PS1" ] && command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi
