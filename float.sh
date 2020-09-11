#!/bin/bash

source ./float.ini

VIP=${IPMASK/\/[0-9]*/}

# Float up
function float_up() {
    ip link add address ${VMAC} ${VDEVICE} link ${HDEVICE} type macvlan mode bridge
    ip a add ${IPMASK} dev ${VDEVICE}
    ip link set dev ${VDEVICE} up
    ip route add ${GATEWAY} dev ${VDEVICE}
}

# Float down
function float_down() {
    ip route del ${GATEWAY} dev ${VDEVICE}
    ip link set dev ${VDEVICE} down
    ip link del ${VDEVICE}
}

# Float status
function float_status() {
    if (ip link show | egrep -q "${VDEVICE}@${HDEVICE}: .* state UP")
    then
        VLNKUP=true
        echo "Link ${VDEVICE} up" 
    else
        VLNKUP=false
        echo "Link ${VDEVICE} down" 
    fi

    if (ping ${VIP} -q -w1> /dev/null) 
    then
	VIPUP=true
	echo "VIP ${IP} is up"
    else
	VIPUP=false
	echo "VIP ${IP} is down"
    fi
}

# main

if [ "$1" == "up" ]
then
    float_up
elif [ "$1" == "down" ]
then
    float_down
elif [ "$1" == "status" ]
then
    float_status
fi
	
