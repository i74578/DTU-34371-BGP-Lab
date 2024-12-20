# BGP-Hijacking

---
This demonstrates a BGP Hijacking attack where the attacker **router-2** hijacks the communications between the AS 1 (router 1, host 1) and AS 4 (router 4, host 4). With this PoC 2 attacks are demonstrated; a simple DOS attack and a http hijacking attack. 

## Running the lab
To run the lab enter the directory and run
```
sudo docker compose up
```

## Access Host 1

Host 1 runs a web browser available on [localhost:3000](http://localhost:3000). From this browser we can try to access the Host 2 http server at [http://10.202.4.202](http://10.202.4.202) in order to demonstrate the 2 attacks.

## DOS attack
You can try to access Host 2 at [http://10.202.4.202](http://10.202.4.202) before and after the DoS attack to showcase that the service is unreachable.
The DoS attack is performed by making router 2 anonce that it is directly connected to 10.202.4.202/32. This is attack is performed by uncommenting the following line inside the config/bgpd2.conf
```
network 10.202.4.202/32
```
The router or BGP service has to be restarted after this change is made.

## HTTP Hijack

To demostrate the http hijacking (redirection) you need to make sure that the DOS attack is active and working.
To initiate the attack run

```
docker exec -it router-2 http-attack
```

If you try to access Host 2 at [http://10.202.4.202](http://10.202.4.202)you will see that the website has changed. 
**Note:** Due to the firefox's cache storage it takes a will to see website change, to speed things up you can clear the cache by going to settings - search for cache - clear cache.
