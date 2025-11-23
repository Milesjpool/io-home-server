#! /bin/bash

(cd ..; ./install.sh)

source private.env
source global.env

exec_user=${SUDO_USER:-$USER}

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

sudo usermod -aG docker "$exec_user"

sudo cp powertop-autotune.service \
  amd-epp.service \
  amdgpu-lowpower.service \
  /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable --now \
  docker \
  powertop-autotune.service \
  amd-epp.service \
  amdgpu-lowpower.service

gsettings set org.gnome.SessionManager logout-prompt false
sudo systemctl set-default multi-user.target

# Setup NAS Media mount
MNT_DIR='/mnt/media'
MNT_GROUP='media'
sudo mkdir -p $MNT_DIR
sudo groupadd $MNT_GROUP
sudo usermod -aG $MNT_GROUP $exec_user
echo $exec_user

if sudo [ ! -f $NAS_CRED_FILE ]; then
  echo "Please enter the following NAS details."

  if [ -z "$NAS_HOST" ]; then
    read -p "  Hostname: " NAS_HOST
    echo
    echo "NAS_HOST='$NAS_HOST'" | sudo tee -a 'private.env' > /dev/null
  fi

  read -p "  Username: " nas_user
  read -s -p "  Password: " nas_pass
  echo
  echo "username=$nas_user" | sudo tee $NAS_CRED_FILE > /dev/null
  echo "passowrd=$nas_pass" | sudo tee -a $NAS_CRED_FILE > /dev/null

  sudo chmod 600 $NAS_CRED_FILE

  echo "//$NAS_HOST/media $MNT_DIR cifs credentials=$NAS_CRED_FILE,vers=3.0,uid=$exec_user,gid=$MNT_GROUP 0 0" | sudo tee -a /etc/fstab
fi

source private.env
echo "=== Server Configuration ==="

read -p "Server LAN IP [$SERVER_LAN_IP]: " input
SERVER_LAN_IP="${input:-$SERVER_LAN_IP}"

read -p "Public address [$SERVER_PUBLIC_URL]: " input
SERVER_PUBLIC_URL="${input:-$SERVER_PUBLIC_URL}"

cat > private.env <<EOF
SERVER_LAN_IP='$SERVER_LAN_IP'
SERVER_PUBLIC_URL='$SERVER_PUBLIC_URL'
EOF