#!/bin/bash

# outputs "0 192.168.10.186 1 192.168.10.187"
IPADDRS=$(/sbin/ifconfig | grep 'inet addr:\|inet Adresse:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1,"x","on"}') >/dev/null

# let user choose ip addr
SFMTSERVER_IPADDR=$(mktemp)
dialog --backtitle "SWISSFM Server IP" \
       --radiolist "Please choose ip address to bind sfmtserver service" \
       15 55 5 $IPADDRS \
       2> $SFMTSERVER_IPADDR
SFMTSERVER_IPADDR=$(cat $SFMTSERVER_IPADDR)

# eval exit code -> ok or cancel pressed?
case $? in
  0)
    echo -e "$SFMTSERVER_IPADDR\tsfmtserver" >>/etc/hosts
    exit 0;;
  1)
    >&2 echo "Cancel pressed."
    exit 1;;
  255)
    >&2 echo "ESC pressed."
    exit 1;;
esac