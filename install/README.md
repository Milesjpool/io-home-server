This directory is intended to serve as the base for setting up a new server, with a fresh install of Ubuntu.

In lieu of automating it (I'll do that next time), here's a list of things I've done:
- Build the computer.
- Enter BIOS
- - Install latest BIOS
- - Set AC Power Back to 'Memory' (i.e. start the pc if it was on previously)
- - Enable ErP
- - Enable Eco CPU mode (in tweaking and in overclocking)
- - Enable XMP
- - Enable Resizeable BAR for GPU
- - Set Power Supply Idle Control to Low Current Idle
- - Enable PCIE ASPM Mode

- - Set low-noise fan-curve
- Flash boot-drive using Etcher
- Insert bootable media, and install OS
- - Follow manual process, or ideally use an autoinstall.yml 


TODO: 
- convert _autoinstall-user-data.yml_ into an _autoinstall.yml_
- - find a way to provide a password at install-time, or prompt to change it later.
- - Front-load any packages to install-time
- Add any other BIOS changes, as I make them or remember them.
