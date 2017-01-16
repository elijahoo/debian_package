#!/bin/bash

# outputs "nobody 65534
#          sfmservice 1000
#          swissfm 1002
#          admin 1001"
USERS=$(getent passwd | awk -F: '$3 > 999 {print $1 , $3}') >/dev/null

COUNTER=1
TO_CHOOSE=""

while read -r line;do
  echo "$line"
  TO_CHOOSE="$TO_CHOOSE $line off"
  let COUNTER=COUNTER+1
done<<<"$USERS"

# create temporary variable
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

# show dialog & let user choose users
dialog --backtitle "Select all users to be deleted" --checklist "Available users:" 10 40 $COUNTER $TO_CHOOSE 2> $tempfile
TO_DEL=`cat $tempfile`

# eval exit code -> ok or cancel pressed?
case $? in
  0)
    for d in $TO_DEL; do
      # remove leading and ending ""
      d="${d//\"}"
      if getent passwd $d > /dev/null; then
        echo -n "Removing user $d with home-directory ."
        userdel -f -r $d
        echo " done"
      fi
    done
    exit 0;;
  1)
    >&2 echo "Cancel pressed."
    exit 1;;
  255)
    >&2 echo "ESC pressed."
    exit 1;;
esac
