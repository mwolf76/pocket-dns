# Pocket DNS

A lightweight portable DNS server, designed with SOHO applications in mind.

## Motivation

This project originated from a personal use-case. I wanted to be able to efficiently manage an arbitrary number of
DHCP-configured hosts in my internal network, _while having no access to the DHCP server_ (which is some closed box,
managed by my ISP). The idea came to me out of the dissatisfaction of having to maintain large `/etc/hosts` file on
multiple hosts.

Portable DNS is a simple DNS server that uses a NoSQL keystore as its back-end. hosts can announce themselves by sending
an HTTP request with its hostname and IP. This information will immediately become available to all the other hosts. The
DNS server only replies with authoritative answers within the local search domain (by default: localdomain). The
intended usage is then to have it as a primary DNS server, while keeping one more general DNS server as secondary.

For example, here is my `/etc/resolv.conf` (same for all the hosts in `localdomain`).

```bash
search localdomain
nameserver 192.168.178.26
nameserver 192.168.178.1
```

In the example above, the first entry is for portable DNS, while the second nameserver is the ISP's.

## Server installation

Not there yet. For the time being, the serve can be started with `docker-compose`.

```bash
$ docker-compose up --build -d

[... yadda yadda yadda ...]
Creating pocket-dns_redis_1 ... done
Creating pocket-dns_webdis_1 ... done
Creating pocket-dns_app_1    ... done
```

## Announcing

In order to let itself known on the network, any participating host announces itself by sending a message to
the http://announcements:6380 end-point. From that moment on, the other hosts within the `localdomain` will be able to
resolve its name. No more fiddling with `/etc/hosts` required. All the entries in the database, except the one for the
announcements' registry itself, expire automatically in 30 minutes. A systemd service and timer in the hosts take care
of refreshing the entry for that particular host before the corresponding entry in the registry expires. This allows
hosts to join and leave the network arbitrarily, with no concern of leaving behind stale DNS entries.

```bash
$ sudo make -C host/ install
[sudo] password for markus: 
make: Entering directory '/home/markus/Code/markus/2021/pocket-dns/host'
install scripts/announce /usr/local/bin
install systemd/announce.service /etc/systemd/system
install systemd/announce.timer /etc/systemd/system
systemctl daemon-reload
systemctl start announce.service
systemctl enable announce.timer
make: Leaving directory '/home/markus/Code/markus/2021/pocket-dns/host'
```

```bash
$ sudo journalctl -u announce.service
[...]

Dec 20 19:00:46 waylon systemd[1]: Started Announce this host to the pocket-dns server.
Dec 20 19:00:46 waylon announce[24691]: success: new IP for waylon is 192.168.178.12, expires in 1800 seconds.
Dec 20 19:00:46 waylon systemd[1]: announce.service: Succeeded.
```

```bash
$ sudo systemctl list-timers
NEXT                         LEFT          LAST                         PASSED    UNIT                         ACTIVATES
Sun 2020-12-20 19:25:46 CET  10min left    Sun 2020-12-20 18:58:52 CET  16min ago announce.timer               announce.service
[...]
```

Name resolution is now possible from any other host in the

```bash
markus@barney:~/Code/markus/pocket-dns
[[ main ]]$ ping -c4 waylon
PING waylon.localdomain (192.168.178.12) 56(84) bytes of data.
64 bytes from 192.168.178.12 (192.168.178.12): icmp_seq=1 ttl=64 time=0.242 ms
64 bytes from 192.168.178.12 (192.168.178.12): icmp_seq=2 ttl=64 time=0.262 ms
64 bytes from 192.168.178.12 (192.168.178.12): icmp_seq=3 ttl=64 time=0.263 ms
64 bytes from 192.168.178.12 (192.168.178.12): icmp_seq=4 ttl=64 time=0.302 ms

--- waylon.localdomain ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 49ms
rtt min/avg/max/mdev = 0.242/0.267/0.302/0.024 ms
```

## Name resolution

```bash
$ dig buster.localdomain

; <<>> DiG 9.11.5-P4-5.1+deb10u2-Debian <<>> buster.localdomain
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 9794
;; flags: qr rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;buster.localdomain.		IN	A

;; ANSWER SECTION:
buster.localdomain.	3600	IN	A	192.168.178.35

;; Query time: 1 msec
;; SERVER: 192.168.178.26#53(192.168.178.26)
;; WHEN: Sun Dec 20 18:45:56 CET 2020
;; MSG SIZE  rcvd: 70
```

## Listing all known hosts

```bash
$ curl -s 'http://announcements:6380/keys/*' | jq
{
  "keys": [
    "waylon",
    "announcements",
    "barney",
    "buster"
  ]
}
```

## Fetching the IP for a host via HTTP

```bash
$ curl -s 'http://announcements:6380/get/barney' | jq -r ".get | @text"
192.168.178.26
```
