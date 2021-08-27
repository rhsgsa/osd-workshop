#!/bin/bash

cd `dirname $0`
BASE=`pwd`
cd - >> /dev/null

docker run \
  --name dashboard \
  -it \
  --rm \
  -p 8080:10080 \
  -v ${BASE}/../workshop_content/workshop:/opt/app-root/workshop \
  -e USERNAME=user1 \
  -e CLUSTER_SUBDOMAIN=apps.test.example.com \
  -e API_URL=https://api.example.com:443 \
  ghcr.io/kwkoo/workshop-dashboard:4.7
