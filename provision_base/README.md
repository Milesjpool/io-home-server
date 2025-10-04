# io-home-server

## Base provisioning
This section will capture everthing required at runtime for my personal server setup, including services, containerisation, and routing.

As Git won't be installed on the serer,  to provision the machine, run the following:

```
wget https://github.com/Milesjpool/io-home-server/archive/main.zip -O ~/io-home-server.zip

unzip io-home-server.zip

cd io-home-server-main/provision_base

./install.sh
```
