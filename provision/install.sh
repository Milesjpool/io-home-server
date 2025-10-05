#! /bin/bash

sudo apt update
sudo apt upgrade -y

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

sudo apt install "linux-tools-$(uname -r)"

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

if ! sudo ss -tlnp | grep -q sshd; then
  read -p "SSH Port [22]: " input_port
  SSH_PORT=${input_port:-22}

  echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
  echo "Port $SSH_PORT" | sudo tee -a /etc/ssh/sshd_config

  sudo ufw allow $SSH_PORT/tcp
fi

sudo systemctl enable --now ssh
echo 'y' | sudo ufw enable
