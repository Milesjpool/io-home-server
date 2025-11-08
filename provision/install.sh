#! /bin/bash

source private.env

sudo apt update
sudo apt upgrade -y

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

sudo apt install "linux-tools-$(uname -r)"
sudo apt install "linux-headers-$(uname -r)"

GRUBFILE="/etc/default/grub"
if ! grep -q 'amd_pstate' "$GRUBFILE"; then
  echo "Setting amd_pstate";
  sudo sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 amd_pstate=active"/' /etc/default/grub
fi

ASPM_POLICY='powersave'
if ! grep -q 'pcie_aspm.policy' "$GRUBFILE"; then
  echo "Setting pcie_aspm.policy";
  sudo sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT="[^"]*\)"/\1 pcie_aspm.policy='$ASPM_POLICY'"/' /etc/default/grub
fi

sudo update-grub

if [ -z "$SSHD_PORT" ]; then
  read -p "SSH Port [22]: " input_port
  SSHD_PORT=${input_port:-22}
  echo "SSHD_PORT='$SSHD_PORT'" | sudo tee -a private.env >/dev/null
fi

if ! sudo ss -tlnp | grep -q sshd; then
  echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
  echo "Port $SSHD_PORT" | sudo tee -a /etc/ssh/sshd_config

  sudo ufw allow $SSHD_PORT/tcp comment 'SSH'
fi

sudo systemctl enable --now ssh
echo 'y' | sudo ufw enable

echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopasswd-$USER >/dev/null
sudo chmod 0440 /etc/sudoers.d/nopasswd-$USER

sudo usermod -aG video $USER
