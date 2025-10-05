#! /bin/bash

(cd ..; ./install.sh)


# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

gsettings set org.gnome.SessionManager logout-prompt false

sudo systemctl enable --now docker
USER_TO_ADD=${SUDO_USER:-$USER}
sudo usermod -aG docker "$USER_TO_ADD"


sudo tee /etc/systemd/system/powertop-autotune.service >/dev/null <<'EOF'
[Unit]
Description=Powertop autotune
[Service]
Type=oneshot
ExecStart=/usr/sbin/powertop --auto-tune
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now powertop-autotune.service

sudo tee /etc/systemd/system/amd-epp.service >/dev/null <<'EOF'
[Unit]
Description=Set AMD EPP to power
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for c in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo power > "$c"; done'
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable --now amd-epp.service
