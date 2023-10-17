#!/bin/bash
#$1 域名   $2 dns
time=`date`
tt=`/usr/bin/nslookup $1  $2|grep  "Address: 9.99.999.999"`
ss=`echo $?`
if  (( $ss == "0" )); then
echo "域名正常"
echo  "$time $1 域名正常" >>/root/dns.log
else
echo "$time $1 域名被劫持" >>/root/dns.log

fi
