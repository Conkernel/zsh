mkdir ~/.config/zsh -p


echo "" > ~/.zshrc

rm -rf ~/.config/zsh

git clone https://github.com/Conkernel/zsh.git ~/.config/zsh

rm -rf ~/powerlevel10k

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k


rm ~/powerlevel10k/.git -rf

rm ~/.fzf/.git -rf


chmod +x ~/.config/zsh/install.sh


# -.-

sudo ~/.config/zsh/install.sh

# -.-