#!/bin/bash

#buildid, posturl, status, errormsg, bundleIdentifier

buildid=$1
posturl=$2
status=$3
errormsg=$4

BODY_DATA="{\"buildId\":$buildid,\"status\":\"$status\",\"errorMessage\":\"$errormsg\"}"
echo "\n**********BUILD_STATUS_UPDATE**********\nPOST_URL=$posturl\nBODY_DATA=["$BODY_DATA"]\n---------------------------------------"
curl -H 'Content-Type: application/json' -X POST -d "$BODY_DATA" $posturl


#update plist if status ==APPLICATION_NOT_PROCESSED, and cehck using watch
