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

exec_user=${SUDO_USER:-$USER}

for pkg in $(cat pkglist); do
  sudo apt-get install -y $pkg;
done

gsettings set org.gnome.SessionManager logout-prompt false

sudo systemctl enable --now docker
sudo usermod -aG docker "$exec_user"

# Auto-tune powertop at startup.
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

# Set CPU power preference.
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

# Setup NAS Media mount
MNT_DIR='/mnt/media'
MNT_GROUP='media'
sudo mkdir -p $MNT_DIR
sudo groupadd $MNT_GROUP
sudo usermod -aG $MNT_GROUP $exec_user
echo $exec_user

NAS_CRED_FILE='/root/.nas-credentials'
if sudo [ ! -f $NAS_CRED_FILE ]; then
  echo "Please enter the following NAS details."
  read -p "  Hostname: " nas_host
  echo
  read -p "  Username: " nas_user
  read -s -p "  Password: " nas_pass
  echo
  echo "username=$nas_user" | sudo tee $NAS_CRED_FILE > /dev/null
  echo "passowrd=$nas_pass" | sudo tee -a $NAS_CRED_FILE > /dev/null

  sudo chmod 600 $NAS_CRED_FILE

  echo "//$nas_host/media $MNT_DIR cifs credentials=$NAS_CRED_FILE,vers=3.0,uid=$exec_user,gid=$MNT_GROUP 0 0" | sudo tee -a /etc/fstab
fi

# Set headless by default (can enable graphical with: sudo systemctl isolate graphical.target)
sudo systemctl set-default multi-user.target

# Set AMD iGPU to low power mode on boot
sudo tee /etc/systemd/system/amdgpu-lowpower.service >/dev/null <<'EOF'
[Unit]
Description=Set AMD iGPU to low power mode
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo battery > /sys/class/drm/card2/device/power_dpm_state; echo low > /sys/class/drm/card2/device/power_dpm_force_performance_level'
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable amdgpu-lowpower.service


