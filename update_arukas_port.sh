#!/bin/bash

if [ $# != 4 ] ; then 
	echo "USAGE: $0 Token:Secret Arukas_Endpoint Arukas_Port Local_Port" 
	echo " e.g.: $0 123456-1234-123456789876:abcdefghijklmnopqrst endpoint.arukascloud.io 8388 1024" 
	exit 1
fi 
rawJson=`curl -s -u $1 https://app.arukas.io/api/containers -H "Content-Type: application/vnd.api+json" -H "Accept: application/vnd.api+json" | jq '.data'`
length=`echo $rawJson | jq "length"`
addr="lost"
port="0"
aimAddr="\"$2\""
aimPort=$3
port_rules="port=$4"
for((i=0;i<$length;i++)) ; do
	endP=`echo $rawJson | jq ".[$i].attributes.end_point"`
	if [ "$endP" = "$aimAddr" ] ; then
		portMapping=`echo $rawJson | jq ".[$i].attributes.port_mappings|.[0]"`
		portMappingLength=`echo $portMapping | jq "length"`
		for((j=0;j<$portMappingLength;j++)) ; do
			cPortJson=`echo $portMapping | jq ".[$j]"`
			cPort=`echo $cPortJson | jq ".container_port"`
			if [ "$cPort" = "$aimPort" ] ; then
				port=`echo $cPortJson | jq ".service_port"`
				addr=`echo $cPortJson | jq ".host" | awk -F '"' '{printf $2}'`
				addr=`host $addr | awk -F 'address ' '{printf $2}'`
				break 2
			fi
		done
	fi
done
if [ "$addr" = "lost" -o "$port" = "0" ] ; then
	echo "Query Failed."
	exit 1
fi

echo "Query OK!Remote Address is $addr:$port"

for i in `firewall-cmd --list-all | awk -F'forward-ports: |\t' '{if($2 ~ /^'"$port_rules"'/)printf $2" ";}'`; do 
	 firewall-cmd --remove-forward-port=$i --permanent
done
firewall-cmd --add-forward-port=port=1000:proto=tcp:toport=$port:toaddr=$addr --permanent
firewall-cmd --reload

