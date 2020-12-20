# pocket-dns

A lightweight portable DNS server

## Motivation

This project originated from a personal use-case. I wanted to be able to efficiently manage an arbitrary number of
DHCP-configured hosts in my internal network, _while having no access to the DHCP server_ (which is some closed box,
managed by my ISP). The idea came to me out of the dissatisfaction of having to maintain large `/etc/hosts` file on
multiple hosts.

Portable DNS is a simple DNS server that uses a NoSQL keystore as its back-end. hosts can announce themselves by sending
an HTTP request with its hostname and IP. This information will immediately become available to all the other hosts. The
DNS server only replies with authoritative answers within the local search domain (by default: localdomain). The
intended usage is then to have it as a primary DNS server, while keeping one more general DNS server as secondary.

For example, here is my `/etc/resolv.conf`

```bash
search localdomain
nameserver 127.0.0.1
nameserver 192.168.178.1
```

In the example above the first entry is for portable DNS, while the second nameserver is the ISP's.

## Announcing

```bash
markus@waylon:~/Code/markus/2021/pocket-dns
[[ main ]]$ scripts/announce 
success: new IP for waylon is 192.168.178.12
```

The host is now resolvable via the DNS. No more fiddling with `/etc/hosts` required.

## Name resolution

TODO

## Listing all known hosts

```bash
$ curl -s 'http://pocket-dns:6380/keys/*' | jq
{
  "keys": [
    "waylon",
    "barney"
  ]
}
```

## Fetching ip for a host

```bash
$ curl -s 'http://pocket-dns:6380/get/barney' | jq
{
"get": "192.168.178.26"
}
```

