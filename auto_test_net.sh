#!/bin/sh

if [ $# != 1 ];then
	echo "Usage: $0 <ip>"
	echo "Such as: $0 192.168.2.121"
	exit 1
fi

IP=$1

IP_LEN=`echo ${#IP}`

LAST_STR_IN_IP=`echo $IP | awk -F '.' '{print $NF}'`
LAST_STR_IN_IP_LEN=`echo ${#LAST_STR_IN_IP}`

PREVIOUS_STR_IN_IP_LEN=`expr $IP_LEN - $LAST_STR_IN_IP_LEN`
PREVIOUS_STR_IN_IP=`echo ${IP::$PREVIOUS_STR_IN_IP_LEN}`

DEST_IP=${PREVIOUS_STR_IN_IP}1

NET_INTERFACE_TXT="net_interface.txt"
ifconfig -a | grep HWaddr | awk -F ' ' '{print $1}' > $NET_INTERFACE_TXT

if [ -f $NET_INTERFACE_TXT ];then
	#shutdown every net interface
	while read line
	do
		ifconfig $line down
	done < $NET_INTERFACE_TXT

	#ping every net interface
	while read line
	do
		ifconfig $line $IP
		ping -c 2 $DEST_IP
		ifconfig $line down
	done < $NET_INTERFACE_TXT


	rm $NET_INTERFACE_TXT
fi
