#!/bin/zsh
# install.sh

DOTFILES_DIR="$HOME/Jun_Dotfiles"

# 创建符号链接
ln -sf "$DOTFILES_DIR/Mac/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/Mac/git/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/Mac/vim/.vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES_DIR/Mac/config/nvim" "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/Mac/config/yazi" "$HOME/.config/yazi"
ln -sf "$DOTFILES_DIR/Mac/tmux/tmux.conf" "$HOME/.tmux.conf"