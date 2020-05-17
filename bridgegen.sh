ifconfig eth0 0.0.0.0
ifconfig eth1 0.0.0.0
brctl addbr bridge0
brctl addif bridge0 eth0
brctl addif bridge0 eth1
ifconfig bridge0 up

