#! /bin/bash

(cd ..; ./install.sh)

for repo in $(cat repolist); do
  sudo add-apt-repository -y $repo;
done

wget -O - https://repo.steampowered.com/steam/archive/stable/steam.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/steam.gpg
echo "deb [signed-by=/usr/share/keyrings/steam.gpg] https://repo.steampowered.com/steam/ stable steam" | \
  sudo tee /etc/apt/sources.list.d/steam.list


sudo apt update
sudo apt full-upgrade

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub app.zen_browser.zen
