#! /bin/bash

sudo apt update
sudo apt upgrade -y

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done


if ! sudo ss -tlnp | grep -q sshd; then
  read -p "SSH Port [22]: " input_port
  SSH_PORT=${input_port:-22}

  echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
  echo "Port $SSH_PORT" | sudo tee -a /etc/ssh/sshd_config

  sudo ufw allow $SSH_PORT/tcp
fi

sudo systemctl enable --now ssh
echo 'y' | sudo ufw enable
