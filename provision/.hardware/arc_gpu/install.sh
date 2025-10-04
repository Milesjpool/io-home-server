#! /bin/bash

for repo in $(cat repolist); do
  sudo add-apt-repository -y $repo;
done

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done
