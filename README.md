# SWISSFM Tool Debian package maker

This tool automate the build of a debian package for SWISSFM Tool software modules

## How to use
* usage: sfmonline/build.sh <RELEASE-GIT-TAG>
* sfmonline/build.sh v3.2.7.4


## Util commands

# test install
sudo apt-get update && sudo apt-get clean && sudo apt-get install sfmonline

# test removal
sudo apt-get remove sfmonline && sudo apt-get autoremove

# local force uninstall
sudo rm -f /var/lib/dpkg/info/sfmonline.* && sudo dpkg --purge sfmonline
