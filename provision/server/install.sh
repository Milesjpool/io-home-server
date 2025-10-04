#! /bin/bash

(cd ..; ./install.sh)

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

gsettings set org.gnome.SessionManager logout-prompt false
