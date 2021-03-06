#!/bin/sh

switch_ip=10.0.0.10
switch_netmask=255.0.0.0
gateway_ip=10.0.0.1
controller_ip=10.0.0.1
controller_port=6633
local_ip=127.0.0.1
local_port=6632

ofs_dir="/root/ofs-sw"
interfaces="eth1,eth2,eth3,eth4"
ofdatapath_options="--no-slicing"
ofprotocol_options="--inactivity-probe=90"

#--datapath-id must be exactly 12 hex digits
id_num=`echo $switch_ip | awk -F '.' '{print $4}'`
if [ $id_num -lt 10 ]; then
    datapath_id=00000000000$id_num
    mac_d1=00
    mac_d2=0$id_num
elif [ $id_num -lt 100 ]; then
    datapath_id=0000000000$id_num
    mac_d1=00
    mac_d2=$id_num
elif [ $id_num -lt 200 ]; then
    datapath_id=0000000000$id_num
    mac_d1=01
    mac_d2=`echo $id_num | cut -c 2-3`
else
    datapath_id=000000000$id_num
    mac_d1=02
    mac_d2=`echo $id_num | cut -c 2-3`
fi

echo "Networking Initial, Please wait..."
# Due to driver issue, networking interfaces should be set up, then down at first.
ifconfig eth0 down

ifconfig eth0 hw ether 00:0a:35:$mac_d1:$mac_d2:00
sleep 1

ifconfig eth0 $switch_ip netmask $switch_netmask up
ifconfig lo up
sleep 1

ret=`route | grep "default" | awk '{print $1}'`
if [ ! $ret ]; then
    route add default gw $gateway_ip
fi

echo "Network Interfaces Initial Done"

# setup 1000basex pcs-pma
/mnt/tools/wrreg 0x43d00500 0x50
/mnt/tools/wrreg 0x43d40500 0x50
/mnt/tools/wrreg 0x43d80500 0x50
/mnt/tools/wrreg 0x43dc0500 0x50

/mnt/tools/rdreg 0x43d00500 4
/mnt/tools/rdreg 0x43d40500 4
/mnt/tools/rdreg 0x43d80500 4
/mnt/tools/rdreg 0x43dc0500 4

/mnt/tools/wrreg 0x43d00508 0x1140
/mnt/tools/wrreg 0x43d40508 0x1140
/mnt/tools/wrreg 0x43d80508 0x1140
/mnt/tools/wrreg 0x43dc0508 0x1140

/mnt/tools/wrreg 0x43d00504 0x01004800
/mnt/tools/wrreg 0x43d40504 0x01004800
/mnt/tools/wrreg 0x43d80504 0x01004800
/mnt/tools/wrreg 0x43dc0504 0x01004800
sleep 1

/mnt/tools/wrreg 0x43d00504 0x01008800
/mnt/tools/wrreg 0x43d40504 0x01008800
/mnt/tools/wrreg 0x43d80504 0x01008800
/mnt/tools/wrreg 0x43dc0504 0x01008800

/mnt/tools/rdreg 0x43d00500 4
/mnt/tools/rdreg 0x43d40500 4
/mnt/tools/rdreg 0x43d80500 4
/mnt/tools/rdreg 0x43dc0500 4

# modify timing of eth-rgmii
/mnt/tools/wrreg 0x43c00500 0x50
/mnt/tools/wrreg 0x43c00508 0xf1e7
/mnt/tools/wrreg 0x43c00504 0x00184800
/mnt/tools/wrreg 0x43c00504 0x00188800
/mnt/tools/rdreg 0x43c0050c 1
/mnt/tools/wrreg 0x43c00508 0xf1e7
/mnt/tools/wrreg 0x43c00504 0x00184800
/mnt/tools/wrreg 0x43c00504 0x00188800
/mnt/tools/rdreg 0x43c0050c 1
/mnt/tools/wrreg 0x43c00508 0xf1e7
/mnt/tools/wrreg 0x43c00504 0x02184800
/mnt/tools/wrreg 0x43c00504 0x02188800
/mnt/tools/rdreg 0x43c0050c 1
/mnt/tools/wrreg 0x43c00508 0xf1e7
/mnt/tools/wrreg 0x43c00504 0x03184800
/mnt/tools/wrreg 0x43c00504 0x03188800
/mnt/tools/rdreg 0x43c0050c 1

# modify timing of eth-1000basex
/mnt/tools/wrreg 0x43d00500 0x50
/mnt/tools/wrreg 0x43d00508 0xf1e7
/mnt/tools/wrreg 0x43d00504 0x00184800
/mnt/tools/wrreg 0x43d00504 0x00188800
/mnt/tools/rdreg 0x43d0050c 1
/mnt/tools/wrreg 0x43d00508 0xf1e7
/mnt/tools/wrreg 0x43d00504 0x00184800
/mnt/tools/wrreg 0x43d00504 0x00188800
/mnt/tools/rdreg 0x43d0050c 1
/mnt/tools/wrreg 0x43d00508 0xf1e7
/mnt/tools/wrreg 0x43d00504 0x02184800
/mnt/tools/wrreg 0x43d00504 0x02188800
/mnt/tools/rdreg 0x43d0050c 1
/mnt/tools/wrreg 0x43d00508 0xf1e7
/mnt/tools/wrreg 0x43d00504 0x03184800
/mnt/tools/wrreg 0x43d00504 0x03188800
/mnt/tools/rdreg 0x43d0050c 1


# download_flow_entry(default)
/mnt/tools/download_flow_entry /mnt/tools/test.txt
