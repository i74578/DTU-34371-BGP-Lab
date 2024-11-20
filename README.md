# BGP-Lab
---

## Running the lab
To run the lab enter the directory and run
```sudo docker compose up```

## The idea:

The idea is to create multiple autonomous systems, each with there own routers and clients. Theses AS should be able to talk to each other using the BGP protocol (specifically Openbgp).


## In practice:

To actually implement the mentioned infrastructure, we have to jump trough a couple of hoops since we are using docker. The fist issue is that we want to be able to create our own router for a docker network. To do this we can follow multiple approaches like:
- **Bridge networks**: They create there own bridge interfaces on the host, that defaults as the gateway for all containers using this network. A work around, is to create a "router" container and manually change the default gateway for all containers using the bridge network by running the `ip route add default via <ip>` command.
- **ipvlan**: This is a very flexible network approach, that essentially binds all containers to a 'master' interface of the host, allowing them to appear as a part of the 'local' network. ipvlan have 2 modes L2 and L3 with the difference being that in L2 all containers share the MAC of the host interface, whereas on L3 each container has its own MAC.

In this specific docker-compose file I chose to use the bridge networkapproach since I (mistakenly) though that it would be easier (ipvlan would require to manually create the 'master' interfaces).


### The issue:

The problem that I face is that since each AS uses its own bridge network, we need to add some forwarding rules on the host in order to make the bridge networks able to talk to each other. Even though it sounds easy its a bit of a husle since we need to forward the traffic from the 'router' containers veth pair on the host to all the other veth pair of other 'router' containers.

For example:

```sh
40: br-f86e59b7a8fd: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:56:80:74:2a brd ff:ff:ff:ff:ff:ff
    inet 13.37.0.254/24 brd 13.37.0.255 scope global br-f86e59b7a8fd
       valid_lft forever preferred_lft forever
    inet6 fe80::42:56ff:fe80:742a/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
41: br-d9af2c077129: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:67:26:b2:1e brd ff:ff:ff:ff:ff:ff
    inet 40.4.0.254/24 brd 40.4.0.255 scope global br-d9af2c077129
       valid_lft forever preferred_lft forever
    inet6 fe80::42:67ff:fe26:b21e/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
51: veth2fc684e@if50: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-f86e59b7a8fd state UP group default 
    link/ether 2a:1b:d1:91:6a:df brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::281b:d1ff:fe91:6adf/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
53: veth18edaab@if52: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-d9af2c077129 state UP group default 
    link/ether ae:56:83:70:4d:1e brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::ac56:83ff:fe70:4d1e/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
55: veth240d551@if54: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-f86e59b7a8fd state UP group default 
    link/ether a6:24:35:06:c2:a9 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::a424:35ff:fe06:c2a9/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
57: veth2a5119d@if56: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-d9af2c077129 state UP group default 
    link/ether ba:29:4b:14:aa:ef brd ff:ff:ff:ff:ff:ff link-netnsid 3
    inet6 fe80::b829:4bff:fe14:aaef/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever

```


In the above scenario we will need to figure out which veth pair is the one that is connected to the router containers and the execute 
```sh
iptables -I FORWARD -i <veth of router1> -o <veth of router2> -j ACCEPT
iptables -I FORWARD -i <veth of router2> -o <veth of router1> -j ACCEPT
```
This must be done for every router to router connection.

