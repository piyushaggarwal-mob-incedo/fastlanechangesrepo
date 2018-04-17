#!/bin/sh
#!/bin/bash
#!/usr/bin/env python

#Calling this file
#python fastlane.py $PLATFORM $JSON_URL $SITE_ID $BUILD_ID $POST_URL
#python ./iOS/AppCMS/fastlane.py ios http://appcms-config.s3.amazonaws.com/ced875ee-9c47-45cd-b81e-96ea101dc639/_temp/build/ios/build.json dev-failarmy 680 http://staging4.partners.viewlift.com/dev-failarmy/ios/appcms/build/status
#python fastlane.py appleTv http://appcms-config.s3.amazonaws.com/1452623e-b2c1-4da8-a32b-a7c301c7f289/_temp/build/appleTv/build.json snagfilmstest1 645 http://staging4.partners.viewlift.com/snagfilmstest1/appleTv/appcms/build/status
import urllib, json, subprocess
from collections import OrderedDict
import sys
import os
import requests
import json

fileDirPath = os.path.dirname(os.path.abspath(__file__))
os.chdir(fileDirPath)


# PLATFORM=sys.argv[1]
# JSON_URL=sys.argv[2]
# SITE_NAME=sys.argv[3]
# BUILD_ID=sys.argv[4]
# POST_URL=sys.argv[5]
# BUCKET_NAME = sys.argv[6]
# BUCKET_NAME = sys.argv[7]



PLATFORM='ios'
JSON_URL='https://s3.amazonaws.com/appcms-config/25136615-c757-4129-a39a-deb2ffd86303/build/ios/build.json'
SITE_NAME='snagfilms-fastlane'
BUILD_ID=2
POST_URL='http://viewlifttoolsupgrad-qa.us-east-1.elasticbeanstalk.com'
BUCKET_NAME='appcms-config'
MY_EMAIL_ID='piyush@viewlift.com'


print 'ARGUMENT_LIST\nPLATFORM='+PLATFORM+'\nJSON_URL='+JSON_URL+'\nSITE_ID='+SITE_NAME+'\nBUILD_ID='+str(BUILD_ID)+'\nPOST_URL='+POST_URL+']'
print
CurrentDir = os.getcwd()
print 'PWD = ' + CurrentDir
param = "projectPath='" + CurrentDir + "' BUILD_ID='" + str(BUILD_ID) + "'"

      # "apptentiveKey": null,
      #   "apptentiveAppSignature": null,
      #   "cachedAPIToken": null,
      #   "urbanAirshipProdMasterKey": null,
      #   "urbanAirshipDevMasterKey": null,
      #   "urbanAirshipAppSecret": null,
      #   "appFlyerKey": "teastkey",
      #   "appSectetKey": null,
      #   "googleServiceInfoPlist": "data:;base6

apptentiveKey = ""
apptentiveAppSignature = ""
cachedAPIToken = ""
urbanAirshipProdMasterKey = ""
urbanAirshipDevMasterKey = ""
urbanAirshipAppSecret = ""
appFlyerKey = ""
appSecretKey = ""
googleServiceInfoPlist = ""

def getSensitiveData():
    url = POST_URL + '/appcms/build/data'
    print url
    payload = {
        'platform': PLATFORM,
        'buildId' : BUILD_ID,
        'siteInternalName' : SITE_NAME,
    }
    # Adding empty header as parameters are being sent in payload
    headers = {"Content-Type": "application/json","secretKey" : "df0813d31adc3b10b9884f5caf57d26a"}
    r = requests.post(url, data=json.dumps(payload), headers=headers)
    print(r.json()["data"])

    sensitiveData = r.json()["data"]
    apptentiveKey = sensitiveData["apptentiveKey"]
    apptentiveAppSignature = sensitiveData["apptentiveAppSignature"]
    cachedAPIToken = sensitiveData["cachedAPIToken"]
    urbanAirshipProdMasterKey = sensitiveData["urbanAirshipProdMasterKey"]
    urbanAirshipDevMasterKey = sensitiveData["urbanAirshipDevMasterKey"]
    appFlyerKey = sensitiveData["appFlyerKey"]
    appSecretKey = sensitiveData["appSecretKey"]

    credentailsData =sensitiveData["googleServiceInfoPlist"].split(",")
    splitservices = credentailsData[1]
    print "piyush"
    print splitservices
    crfile = open(CurrentDir + '/crfile.txt', 'w')
    with open(CurrentDir + "/crfile.txt", "a") as myfile:
        crfile.write(splitservices.encode("utf-8"))
    crfile.close()

getSensitiveData()

response = urllib.urlopen(JSON_URL)
data = json.loads(response.read(), object_pairs_hook=OrderedDict)
print data

#Update build Status from QUEUE to INITIATED
#subprocess.call('sh '+ CurrentDir +'/fastlane/PostBuildStatus.sh ' + BUILD_ID +' '+ POST_URL +' "STARTED" "Build Initiated"', shell=True)

try:

    param = ""
    for k in data.keys():
       param = param + k + "='"+ str(data[k]) + "' "

    print param
    bundleIdentifier = "com.piyush.fastlanetest"
    appleTeamId = "AC3B332EWB"
    ituneTeamId = "691013"

    param = param + "projectPath='" + CurrentDir + "' POST_URL='" +POST_URL+ "' SiteName='" + SITE_NAME + "' BUILD_ID='" + str(BUILD_ID) + "' platform='" + PLATFORM  + "' username='" + MY_EMAIL_ID + "' bukcet_name='" + BUCKET_NAME + "' bundleIdentifier='" + bundleIdentifier + "' apple_team_id='" + appleTeamId + "' ituneTeamId='" + ituneTeamId + "' " 
    print param
    print 
    print 'execute.sh '+param

    subprocess.call("sh "+CurrentDir+"/execute.sh " + param, shell=True)
except Exception, e:
    # subprocess.call('sh '+ CurrentDir +'/fastlane/PostBuildStatus.sh ' + BUILD_ID +' '+ POST_URL +' "FAILED" "'+ str(e) +'"', shell=True)
    print '\nError::[' + str(e) + ']'

