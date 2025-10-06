#! /bin/bash

(cd ..; ./install.sh)

for repo in $(cat repolist); do
  sudo add-apt-repository -y $repo;
done

sudo apt update
sudo apt full-upgrade

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub app.zen_browser.zen
