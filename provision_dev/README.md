# io-home-server

## Dev provisioning
This will capture everything to install beyond the base server, required for further development. None of this should be required at run-time.

As this step installs _git_, and this repo is stored in GitHub, there's a bit of a chicken/egg situation. You will need to run the base + dev provisioning before cloning this repo for modification.

Follow the installation instructions described in _provision_base_. Once this is done _cd_ into this directory, and run:

```
./install.sh
```

After this you can clone this repo and modify it as normal.
