# io-home-server

## Base provisioning
This section will the common setup required for all runtime use-cases.

As Git won't be installed initially, to provision the machine, run the following:

```
wget https://github.com/Milesjpool/io-home-server/archive/main.zip -O ~/io-home-server.zip

unzip io-home-server.zip

cd io-home-server-main/provision

./install.sh
```

### Hardware
This directory contains automations for server hardware, drivers etc. Install these as required.

## Manual steps
SSH access will be set-up with PasswordAuthentication enabled. Once you have added one-or-more _authorized_keys_ (e.g. with `ssh-copy-id`) make sure this is disabled.
```
# /etc/ssh/sshd_config

PasswordAuthentication no

```

