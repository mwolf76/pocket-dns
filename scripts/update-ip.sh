#!/bin/bash

# registry end-point
REGISTRY="http://pocket-dns/registry/"

HOST=$(hostname)
ADDR=$(ip a | grep inet | grep 192.168.178 | awk '{ print $2 }' | sed -E 's/\/\S+//')

curl --quiet --header "Content-Type: application/json" --request POST \
     --data "{\"host\":\"$HOST\", \"addr\":\"$ADDR\"}" "$REGISTRY"
