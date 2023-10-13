#!/bin/bash
if [ $2 == "up" ]; then
 echo "Real server ${1} is UP" > /tmp/notify.txt
elif [ $2 == "down" ]; then
 echo "Real server ${1} is DOWN" > /tmp/notify.txt
fi
