#!/bin/bash

REGISTRY="http://localhost:6380"
HOST=$(hostname)
ADDR=$(ip a | grep inet | grep 192.168.178 | awk '{ print $2 }' | sed -E 's/\/\S+//')

[[ $(curl --silent "${REGISTRY}/set/${HOST}/${ADDR}" | jq -r '.set[1]') != "OK" ]] && exit 1

echo "new IP for ${HOST} is ${ADDR}"
