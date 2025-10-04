#! /bin/bash

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

KEYFILE="$HOME/.ssh/id_ed25519"
if [ ! -f "$KEYFILE" ]; then
  echo "Generating SSH keys for GitHub"
  read -p "SSH Key Identifier: " comment;
  ssh-keygen -t ed25519 -f $KEYFILE -C "$comment";

  eval "$(ssh-agent -s)"
  ssh-add $KEYFILE

  cat "$KEYFILE.pub"
  echo -e "Enter this key \e]8;;https://github.com/settings/keys\e\\here\e]8;;\e\\"
  read -p "Press [Enter] to resume."
fi

DOTFILES_PATH="$HOME/.dotfiles"
if [ ! -d $DOTFILES_PATH ]; then
  git clone git@github.com:milesjpool/.dotfiles.git $DOTFILES_PATH

  [ -f "$HOME/.bashrc" ] && mv "$HOME/.bashrc.private"
  [ -f "$HOME/.gitconfig" ] && mv "$HOME/.gitconfig.private"
  [ -f "$HOME/.vimrc" ] && mv "$HOME/.vimrc.private"
fi

stow -R --dir="$DOTFILES_PATH" --target="$HOME" git vim shell bash

GIT_CONFIG="$HOME/.gitconfig.private";
if [ ! -f $GIT_CONFIG ]; then 
  read -p "Git user name: " username;
  git config -f ~/.gitconfig.private user.name "$username"
  read -p "Git email: " email;
  git config -f ~/.gitconfig.private user.email "$email"
fi

