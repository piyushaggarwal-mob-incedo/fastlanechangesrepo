import urllib, json, subprocess
from collections import OrderedDict
import sys
import os
import requests
import json
import time;


fileDirPath = os.path.dirname(os.path.abspath(__file__))
platform = sys.argv[1];
print platform
url = sys.argv[2];
print url




print "******************************************8"

headers = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.155 Safari/537.36',
    'cache-control': 'private, max-age=0, no-cache'
}

url=url+"?x="+str(time.time())
r = requests.get(url, headers=headers)

print r.text

print "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT*********8"

print r.json

print "******************************************8"

urllib.urlcleanup()
response = urllib.urlopen(url)
urllib.urlcleanup()

data = json.loads(r.text, object_pairs_hook=OrderedDict)


print (data)


print "******************************************8"


file = open(fileDirPath + '/AppCMS/src/main/assets/version.properties', 'w')
file.close()
param = ""
siteName = sys.argv[3]
buildId = sys.argv[4]
uploadHostName = sys.argv[5]
print('Upload Host Name --> ' + uploadHostName)
bucketName = sys.argv[6]
myEmailId=sys.argv[7]
sampleSlackWebHookUrl="https://hooks.slack.com/services/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"

siteId = ""
baseUrl = ""
hostName = ""
appResourcePath = ""
appName = ""
fullDescription = ""
shortDescription = ""
appVersionName = ""
appVersionCode = ""
appPackageName = ""
apptentiveApiKey = ""
keystoreFileName = ""
aliasName = ""
keystorePass = ""
track = ""
jsonKeyFile = ""
promoVideo = ""
appTitle = ""
featureGraphic = ""
promoGraphic = ""
tvBanner = ""
appIcon = ""
urbanAirshipDevKey = ""
urbanAirshipDevSecret = ""
urbanAirshipProdKey = ""
urbanAirshipProdSecret = ""
isUrbanAirshipInProduction = ""
gcmSender = ""
facebookAppId = ""
appsFlyerDevKey = ""
appsFlyerProdKey = ""
whatsNew = ""
keyval = ""
googleCredentialsFile = "googleCredentialsFile"

print "******************************************************"

print platform
print buildId
print siteName

print "*******************************************************"

def getKeyStorePassword():
    url = uploadHostName + '/appcms/build/data'

    payload = {
        'platform': platform,
        'buildId' : buildId,
        'siteInternalName' : siteName,
        'fieldName' : 'keystorePassword'
    }
    # Adding empty header as parameters are being sent in payload
    headers = {"Content-Type": "application/json","secretKey" : "df0813d31adc3b10b9884f5caf57d26a"}
    r = requests.post(url, data=json.dumps(payload), headers=headers)
    print(r.json()["data"])
    keystorePass = r.json()["data"]
    return keystorePass

splitservices = ""

def getServicesFile():
    url = uploadHostName + '/appcms/build/data'

    payload = {
        'platform': platform,
        'buildId' : buildId,
        'siteInternalName' : siteName,
        'fieldName' : 'googleServicesFile'
    }
    # Adding empty header as parameters are being sent in payload
    headers = {"Content-Type": "application/json","secretKey" : "df0813d31adc3b10b9884f5caf57d26a"}
   
    r = requests.post(url, data=json.dumps(payload), headers=headers)
    print "getServicesFile"
    print url
    print payload
    print headers
    print "getServicesFile"

    # print(r.json()["data"])
    credentailsData = r.json()["data"]
    credentailsData =credentailsData.split(",")
    splitservices = credentailsData[1]
    print "piyush"
    print splitservices

    crfile = open(fileDirPath + '/AppCMS/crfile.txt', 'w')
    with open(fileDirPath + "/AppCMS/crfile.txt", "a") as myfile:
        crfile.write(splitservices.encode("utf-8"))
    crfile.close()

getServicesFile()


splitCredentails = ""

def getCredentailsFile():
    url = uploadHostName + '/appcms/build/data'

    payload = {
        'platform': platform,
        'buildId' : buildId,
        'siteInternalName' : siteName,
        'fieldName' : 'googleCredentialFile'
    }
    # Adding empty header as parameters are being sent in payload
    headers = {"Content-Type": "application/json","secretKey" : "df0813d31adc3b10b9884f5caf57d26a"}

    print "getCredentailsFile"
    print url
    print payload
    print headers
    print "getCredentailsFile"



    # headers = {"Content-Type": "application/json","secretKey" : "df0813d31adc3b10b9884f5caf57d26a"}
    r = requests.post(url, data=json.dumps(payload), headers=headers)
    # print(r.json()["data"])
    credentailsData = r.json()["data"]
    credentailsData =credentailsData.split(",")
    splitCredentails = credentailsData[1]
    print "piyush"
    print splitCredentails

    crfile = open(fileDirPath + '/credentialfile.txt', 'w')
    with open(fileDirPath + "/credentialfile.txt", "a") as myfile:
        crfile.write(splitCredentails.encode("utf-8"))
    crfile.close()
    print "piyush"
    print credentailsData

getCredentailsFile()


print data


print "********************************************"
print data["packageName"]
print "********************************************"


for k in data.keys():

    if k == "siteId":
        keyval = "SiteId" + ":" + data[k]
        siteId = data[k]

    elif k == "baseUrl":
        keyval = "BaseUrl" + ":" + data[k]
        baseUrl = data[k]

    elif k == "hostName":
        keyval = "HostName" + ":" + data[k]
        hostName = data[k]

    elif k == "resourcePath":
        keyval = "AppResourcesPath" + ":" + data[k]
        appResourcePath = data[k]

    elif k == "appName":
        keyval = "AppName" + ":" + data[k]
        appName = data[k]

    elif k == "description":
        #keyval = "FullDescription" + ":" + data[k]
        #fullDescription = data[k]
        keyval = "FullDescription"
        fullDescription = "data[k]"
        # with open(fileDirPath + "/fastlane/metadata/android/en-US/full_description.txt",
        #           "w") as myfile:
        #     myfile.write(fullDescription.encode("utf-8") + "\n")

    elif k == "shortDescription":
        keyval = "ShortDescription" + ":" + data[k]
        shortDescription = data[k]
        # with open(fileDirPath + "/fastlane/metadata/android/en-US/short_description.txt",
        #           "w") as myfile:
        #     myfile.write(shortDescription.encode("utf-8") + "\n")

    elif k == "appVersion":
        keyval = "AppVersionName" + ":" + data[k]
        appVersionName = data[k]

    elif k == "packageName":
        keyval = "AppPackageName" + ":" + data[k]
        appPackageName = data[k]

    elif k == "apptentiveApiKey":
        keyval = "ApptentiveApiKey" + ":" + data[k]
        apptentiveApiKey = data[k]

    elif k == "keystoreFile":
        keyval = "KeystorePath" + ":" + data[k]
        keystoreFileName=data[k]
        keystoreFileName=keystoreFileName+"?x="+str(time.time())

    elif k == "keystoreAliasName":
        keyval = "AliasName" + ":" + data[k]
        aliasName = data[k]

    elif k == "track":
        keyval = "Track" + ":" + data[k]
        track = data[k]

    elif k == "jsonKeyFile":
        keyval = "JsonKeyFile" + ":" + data[k]
        jsonKeyFile = data[k]

    elif k == "promoVideo":
        keyval = "PromoVideoUrl" + ":" + data[k]
        promoVideo = data[k]
        # with open(fileDirPath + "/fastlane/metadata/android/en-US/video.txt", "w") as myfile:
        #     myfile.write(promoVideo.encode("utf-8") + "\n")

    elif k == "appTitle":
        keyval = "AppTitle" + ":" + data[k]
        appTitle = data[k]
        # with open(fileDirPath + "/fastlane/metadata/android/en-US/title.txt", "w") as myfile:
        #     myfile.write(appTitle.encode("utf-8") + "\n")

    elif k == "featureGraphic":
        # keyval = "FeatureGraphicUrl" + ":" + data[k]
        featureGraphic = data[k]

    elif k == "promoGraphic":
        # keyval = "PromoGraphicUrl" + ":" + data[k]
        promoGraphic = data[k]

    elif k == "tvBanner":
        # keyval = "TvBannerUrl" + ":" + data[k]
        tvBanner = data[k]

    elif k == "playIcon":
        # keyval = "AppIconUrl" + ":" + data[k]
        appIcon = data[k]

    elif k == "urbanAirshipDevKey":
        # keyval = "UAirshipDevelopmentAppKey" + ":" + data[k]
        urbanAirshipDevKey = data[k]

    elif k == "urbanAirshipDevSecret":
        # keyval = "UAirshipDevelopmentAppSecret" + ":" + data[k]
        urbanAirshipDevSecret = data[k]

    elif k == "urbanAirshipProdKey":
        # keyval = "UAirshipProductionAppKey" + ":" + data[k]
        urbanAirshipProdKey = data[k]

    elif k == "urbanAirshipProdSecret":
        # keyval = "UAirshipProductionAppSecret" + ":" + data[k]
        urbanAirshipProdSecret = data[k]

    elif k == "isUrbanAirshipInProduction":
        # keyval = "UAirshipInProduction" + ":" + data[k]
        isUrbanAirshipInProduction = data[k]

    elif k == "gcmSender":
        keyval = "GcmSender" + ":" + data[k]
        gcmSender = data[k]

    elif k == "facebookAppId":
        keyval = "FacebookAppId" + ":" + data[k]
        facebookAppId = data[k]

    elif k == "appsFlyerDevKey":
        keyval = "AppsFlyerDevKey" + ":" + data[k]
        appsFlyerDevKey = data[k]

    elif k == "appsFlyerProdKey":
        keyval = "AppsFlyerProdKey" + ":" + data[k]
        appsFlyerProdKey = data[k]

    elif k == "whatsnew":
        keyval = "WhatsNew" + ":" + data[k]
        whatsNew = data[k]

    elif k == "slackWebHook":
        sampleSlackWebHookUrl = data[k]

        
        # with open(fileDirPath + "/fastlane/metadata/android/en-US/changelogs/" + appVersionCode + ".txt","w") as myfile:
        #      myfile.write(whatsNew.encode("utf-8") + "\n")
            # else:
            #   keyval = k + ":" + data[k]


    with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")


        # whatsNew = "Here details regarding what's new you are providing for this version"
        # with open(fileDirPath + "/fastlane/metadata/android/en-US/changelogs/"+appVersionCode+".txt", "w") as myfile:
        # myfile.write(whatsNew.encode("utf-8")+"\n")

versionCodeValue = 1
keyval = "AppVersionCode" + ":" + str(versionCodeValue)
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")




#Adding Facebook AppId and GCM Sender ID and Apptentive Key And Further Details and HostName Suffix:



keyval = "UseHLS" + ":" + "false"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")

keyval = "XAPI" + ":" + "vdTAMerEdh8t5t7xtUAa199qBKQuFLXb5cuG93ZF"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")

keyval = "HostNameSuffix" + ":" + "*.http\://arenafootball.viewlift.com/"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")

keyval = "BaseUrl" + ":" + "https\://appcms.viewlift.com/"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")

keyval = "ApptentiveApiKey" + ":" + "ANDROID-ARENA-FOOTBALL-LEAGUE"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")

keyval = "AppsFlyerDevKey" + ":" + "00000000000"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")

keyval = "HostName" + ":" + "http\://arenafootball.viewlift.com/"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")

keyval = "FacebookAppId" + ":" + "1324523080924996"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")


keyval = "ApptentiveSignatureKey" + ":" + "3662489474d4a82ad0f6dda0abfbb19c"
with open(fileDirPath + "/AppCMS/src/main/assets/version.properties", "a") as myfile:
         myfile.write(keyval.encode("utf-8") + "\n")


keystorePass = getKeyStorePassword()

appVersionCode = 1

shortDescription = shortDescription.replace(" ", "_")
whatsNew = whatsNew.replace(" ", "_")


print ")))))))))))))))))))))))))))))))))))))))))))))))))))))))))"
print aliasName
print keystorePass
print ")))))))))))))))))))))))))))))))))))))))))))))))))))))))))"


if platform == "android":
    param = siteId + " " \
        + baseUrl + " " \
        + appVersionName + " '" \
        + appName + "' " \
        + str(appVersionCode) + " " \
        + appPackageName + " " \
        + appResourcePath + " " \
        + keystoreFileName + " " \
        + aliasName + " " \
        + track + " " \
        + googleCredentialsFile + " " \
        + featureGraphic + " " \
        + promoGraphic + " " \
        + tvBanner + " " \
        + appIcon + " " \
        + siteName + " " \
        + str(buildId) + " " \
        + uploadHostName + " " \
        + bucketName + " " \
        + keystorePass + " '" \
        + shortDescription + "' '" \
        + whatsNew + "' '" \
        + myEmailId + "' " \
        + "sampleSlackWebHookUrl"
elif platform == "fireTv":
     param = siteId + " " \
        + baseUrl + " " \
        + appVersionName + " '" \
        + appName + "' " \
        + str(appVersionCode) + " " \
        + appPackageName + " " \
        + appResourcePath + " " \
        + keystoreFileName + " " \
        + aliasName + " " \
        + track + " " \
        + googleCredentialsFile + " " \
        + siteName + " " \
        + str(buildId) + " " \
        + uploadHostName + " " \
        + bucketName + " " \
        + keystorePass + " '" \
        + myEmailId + "' " \
        + "sampleSlackWebHookUrl"

print param

if platform == "android":
    subprocess.call("sh " + fileDirPath + "/fastlanemobilescripts_temp.sh " + param, shell=True)
elif platform == "fireTv":
    subprocess.call("sh " + fileDirPath + "/fastlanetvscripts_temp.sh " + param, shell=True)
