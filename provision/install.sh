#! /bin/bash

sudo apt update
sudo apt upgrade -y

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done
