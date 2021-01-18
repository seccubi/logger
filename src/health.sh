#!/bin/bash

cd /fluent-bit/etc
if [ ! -f .env ]; then
    exit 0
fi
URL=`cat .env`
curl -kf --retry 3 --max-time 5 --retry-delay 1 --retry-max-time 60 "$URL/health" || bash -c 'kill -s 15 -1 && (sleep 10; kill -s 9 -1)'
