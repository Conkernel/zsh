apt install zsh mlocate bat git curl xdg-utils ripgrep exa libnotify-bin     -y

[ -d /etc/zsh ] && mv /etc/zsh /etc/zsh.old 
mv zsh /etc/

[ -d /etc/bat ] && mv /etc/bat /etc/bat.old 
mv bat /etc/



curl -sS https://starship.rs/install.sh | sh
