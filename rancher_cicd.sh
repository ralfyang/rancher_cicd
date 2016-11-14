#!/bin/bash
BARR="============================================================"

## Command check & base package install script as https://github.com/goody80/chk_env/blob/gh-pages/chk_env.sh
curl -sL bit.ly/chk_env | bash

## Make sure the Rancher server URL
#RANCHER="launch.4wish.net"
RANCHER="192.200.10.100:8080"

## Cattle Key setup
CATTLE_ACCESS_KEY="[CATTLE_ACCESS_KEY]"
CATTLE_SECRET_KEY="[CATTLE_SECRET_KEY]"
stack_id="1a5"

## Define the Rancher Host list to /tmp/host.list
echo $BARR
echo " Target instance for deploy "
curl -sL -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" "http://$RANCHER/v1/projects/$stack_id/ipaddresses?kind_notlike=docker&networkId_null" | jq '.data[] | {address}.address' | sed -e 's/"//g'  > /tmp/host.list
echo $BARR

docker_img="registry.4wish.net/vfd/ranking_twice_vote"
docker_img_new="$docker_img:0.1"
docker_img_old="$docker_img:0.2"
service_id="1s1"

curl -u "${CATTLE_ACCESS_KEY}:${CATTLE_SECRET_KEY}" \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d '{
  "inServiceStrategy": {
    "intervalMillis": 2000,
    "batchSize": 1,
    "launchConfig": {
      "kind": "container",
      "networkMode": "managed",
      "privileged": false,
      "publishAllPorts": false,
      "readOnly": false,
      "startOnCreate": true,
      "stdinOpen": true,
      "tty": true,
      "vcpu": 1,
      "imageUuid": "docker:'$docker_img_new'",
      "labels": {
        "io.rancher.container.pull_image": "always"
      },
      "logConfig": {
        "driver": "",
        "config": {}
      },
      "ports": [],
      "dataVolumes": [],
      "dataVolumesFrom": [],
      "dns": [],
      "dnsSearch": [],
      "capAdd": [],
      "capDrop": [],
      "devices": [],
      "dataVolumesFromLaunchConfigs": [],
      "count": null,
      "cpuSet": null,
      "cpuShares": null,
      "description": null,
      "domainName": null,
      "hostname": null,
      "memory": null,
      "memoryMb": null,
      "memorySwap": null,
      "pidMode": null,
      "requestedIpAddress": null,
      "user": null,
      "userdata": null,
      "volumeDriver": null,
      "workingDir": null,
      "networkLaunchConfig": null,
      "version": "86f50706-92d5-4898-a9f5-12694aa224b7"
    },
    "secondaryLaunchConfigs": [],
    "previousLaunchConfig": {
      "imageUuid": "docker:'$docker_img_old'",
      "labels": {
        "io.rancher.container.pull_image": "always",
        "io.rancher.service.hash": "de469702c4ae3abad712948162e804375457be53"
      },
      "logConfig": {},
      "networkMode": "managed",
      "startOnCreate": true,
      "stdinOpen": true,
      "tty": true,
      "kind": "container",
      "privileged": false,
      "publishAllPorts": false,
      "readOnly": false,
      "version": "0",
      "vcpu": 1
    },
    "previousSecondaryLaunchConfigs": [],
    "startFirst": false,
    "fullUpgrade": true
  },
  "toServiceStrategy": null
}' \
"http://$RANCHER/v1/services/$service_id/?action=upgrade"
