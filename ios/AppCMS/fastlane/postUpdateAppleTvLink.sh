#!/bin/bash

echo

echo "POST UPDATE LINK"

echo ${8}
echo ${9}

aws s3 cp $8 s3://appcms-config/${9}/build/appleTv/

MY_IPA_SERVER_URL="http://appcms-config.s3.amazonaws.com/$9/build/appleTv/AppCMS_tvOS.ipa"

echo MY_IPA_SERVER_URL

postUpdateLink(){ #buildid, posturl, status, errormsg
    BODY_DATA="{\"buildId\":${1},\"apkLink\":\"$3\",\"platform\":\"appleTv\"}"
    echo "\n**********BUILD_STATUS_UPDATE**********\UPLOAD_URL=$2\nBODY_DATA=["$BODY_DATA"]\n---------------------------------------"
    curl -H 'Content-Type: application/json' -X PUT -d "$BODY_DATA" $2
}


postUpdateLink $1 ${10} $MY_IPA_SERVER_URL 