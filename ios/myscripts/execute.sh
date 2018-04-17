#!/bin/bash

echo "Piyush"

echo "$@"

echo

echo "Piyush"

echo

echo $1
echo $2
echo $3
echo $4
echo $5
echo $6
echo $7

echo

for ARGUMENT in "$@"
do
    echo $ARGUMENT
done

PLISTBUDDY="/usr/libexec/PlistBuddy"

postBuildStatus(){ #buildid, posturl, status, errormsg
    sh ./fastlane/PostBuildStatus.sh $1 $2 $3 $4 $5 $6 $7 $8
}

postUpdateLink(){ #buildid, posturl, status, errormsg
    BODY_DATA="{\"buildId\":$1,\"apkLink\":\"$3\",\"platform\":\"android\"}"
    echo "\n**********BUILD_STATUS_UPDATE**********\UPLOAD_URL=$2\nBODY_DATA=["$BODY_DATA"]\n---------------------------------------"
    curl -H 'Content-Type: application/json' -X PUT -d "$BODY_DATA" $2
}

downloadFile(){ #url, output, buildid, posturl
    sh ./fastlane/download.sh "${1}" "${2}" "${3}" "${4}"
    OUT=$?
    if [ $OUT -eq 1 ];then
        exit 1
    fi
}

#PARSING VALUES
for ARGUMENT in "$@"
do

KEY=$(echo $ARGUMENT | cut -f1 -d=)
VALUE=$(echo $ARGUMENT | cut -f2 -d=)

case "$KEY" in
platform)           toBuildPlatform=${VALUE} ;;
projectPath)        PROJECT_DIR_PATH=${VALUE} ;;
appName)            CFBundleDisplayName=${VALUE} ;;
appVersion)         CFBundleShortVersionString=${VALUE} ;;
baseUrl)            UIJsonBaseUrl=${VALUE} ;;
bundleIdentifier)   CFBundleIdentifier=${VALUE} ;;
track)              BuildType=${VALUE} ;;
appSecretKey)       AppSecretKey=${VALUE} ;;
siteId)             SiteId=${VALUE} ;;

#Apptentive
apptentiveApiKey)       ApptentiveAppKey=${VALUE} ;;
apptentiveAppSignature) ApptentiveAppSignature=${VALUE} ;;
apptentiveAppKey)       ApptentiveKey=${VALUE} ;;
apptentiveAppId)        ApptentiveAppId=${VALUE} ;;

#AppFlyer
appFlyerAppId)          AppFlyerAPPID=${VALUE} ;;
appFlyerProdKey)        AppFlyerAppKey=${VALUE} ;;

#UrbanAirship
UrbanAirshipDevMasterKey)     UrbanAirshipDevMasterKey=${VALUE} ;;
UrbanAirshipAppKey)  UrbanAirshipAppKey=${VALUE} ;;
UrbanAirshipProdMasterKey)    UrbanAirshipProdMasterKey=${VALUE} ;;
UrbanAirshipAppKey) UrbanAirshipAppKey=${VALUE} ;;
UrbanAirshipChurnTagAvailable) UrbanAirshipChurnTagAvailable=${VALUE} ;;


#facebook
facebookAppId)          FacebookAppID=${VALUE} ;;
bundleURLSchemes)       FacebookBundleURLSchemes=${VALUE} ;;
facebookDisplayName)    FacebookDisplayName=${VALUE} ;;

#google
bundleURLSchemesGoogle) GoogleBundleURLSchemes=${VALUE} ;;
googleClientId)         GoogleClientId=${VALUE} ;;

resourcePath)           ResourceURLPath=${VALUE} ;;

distibutionProfileName) DistibutionProfileName=${VALUE} ;;

POST_URL)               POST_URL=${VALUE} ;;

SITE_ID)                SITE_ID=${VALUE} ;;

BUILD_ID)               BUILD_ID=${VALUE} ;;

associatedDomain01)     AssociatedDomain=${VALUE} ;;

#credential
password)     password=${VALUE} ;;
username)     username=${VALUE} ;;

ituneTeamId) ituneTeamId = ${VALUE} ;;
appleTeamId)    devTeamId=${VALUE} ;;

bukcet_name)    bucketName=${VALUE} ;;
slackWebHook)    slackWebHook=${VALUE} ;;
marketingUrl)    marketingUrl=${VALUE} ;;
supportUrl)      supportUrl=${VALUE} ;;
bukcet_name)    bucketName=${VALUE} ;;


*)
esac
done

MY_POST_URL="${POST_URL}/${SiteName}/android/appcms/build/status"
MY_UPLOAD_URL="${POST_URL}/${SiteName}/appcms/android/build/apk/link"

postBuildStatus ${BUILD_ID} $MY_POST_URL "STARTED" "No ERROR" "Build Successfully Started" 5 false 0


echo "PROJECT_DIR_PATH = $projectPath"
echo "FastlaneResultPath = $projectPath/fastlane"

echo "AppSecretKey = $AppSecretKey"
echo "BuildType = $BuildType"
echo "CFBundleDisplayName = $CFBundleDisplayName"
echo "CFBundleShortVersionString = $CFBundleShortVersionString"
echo "UIJsonBaseUrl = $UIJsonBaseUrl"
echo "CFBundleIdentifier = $CFBundleIdentifier"
echo "SiteId = $SiteId"

#Apptentive
echo "ApptentiveKey = $ApptentiveKey"
echo "ApptentiveAppKey = $ApptentiveAppKey"
echo "ApptentiveAppSignature = $ApptentiveAppSignature"
echo "ApptentiveAppId = $ApptentiveAppId"

#AppFlyer
echo "AppFlyerAPPID = $AppFlyerAPPID"
echo "AppFlyerAppKey = $AppFlyerAppKey"

#UrbanAirship
echo "UrbanAirshipDevKey = $UrbanAirshipDevMasterKey"
echo "UrbanAirshipDevSecret = $UrbanAirshipAppKey"
echo "UrbanAirshipProdKey = $UrbanAirshipProdMasterKey"
echo "UrbanAirshipProdSecret = $UrbanAirshipAppKey"
echo "UrbanAirshipChurnTagAvailable = $UrbanAirshipChurnTagAvailable"


#Facebook
echo "FacebookAppID = $FacebookAppID"
echo "FacebookDisplayName = $FacebookDisplayName"
echo "FacebookBundleURLSchemes = $FacebookBundleURLSchemes"

#google
echo "GoogleClientId = $GoogleClientId"
echo "GoogleBundleURLSchemes = $GoogleBundleURLSchemes"

echo "ResourceURLPath = $ResourceURLPath"

echo "DistibutionProfileName = $DistibutionProfileName"
echo "AssociatedDomain = $AssociatedDomain"
echo "POST_URL=$POST_URL"

echo "AppleDevTeamId = $devTeamId"
echo "iTunes_team_id=$ituneTeamId"

echo "appstoreName=$appstoreName"

echo "iTunes Username = $username"
echo "iTunes Password = *********\n"

AssociatedDomains01="applinks:$AssociatedDomain"
AssociatedDomains02="applinks:www.$AssociatedDomain"


#Configuration Values
ProjectName="Snagfilms"
run_platform="$toBuildPlatform"

# Removing the metadata of the fastlane and hence erasing all the fields.

# if [ "$toBuildPlateform" = "ios" ]
# then
#     run_platform="ios"
#     SchemeName="Snagfilms"

#     #Downloading Resources

#     #------------------Update:Resources--------------------------#
#     ##Replace all Resources
#     copyAssetsPath="$PROJECT_DIR_PATH/Snagfilms/Assets.xcassets/AppIcon.appiconset"
#     copyCastPath="$PROJECT_DIR_PATH/Snagfilms/Resources/Images/CastingImageAssets"
#     copySpashPath="$PROJECT_DIR_PATH/Snagfilms/Resources/Images"

#     echo 's3://appcms-config/$SiteId/build/android/resource/drawable'

#     #Downloading Assests and Copying into the Schema Folder
#     aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/AppIcon.appiconset $copyAssetsPath --recursive
#     aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/CastingImageAssets $copyCastPath --recursive
#     aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/Resources $copySpashPath --recursive


#     InfoPlistPath="$PROJECT_DIR_PATH/$SchemeName/Info.plist"
#     $FacebookBundleURLSchemes="fb227991737252697"
#     $GoogleBundleURLSchemes="gb227991737252697"
#     $FacebookDisplayName=$CFBundleDisplayName

#     #------------------Update:Info-plist--------------------------#
#     ${PLISTBUDDY} -c "Set :CFBundleShortVersionString $CFBundleShortVersionString" $InfoPlistPath
#     ${PLISTBUDDY} -c "Set :CFBundleIdentifier $CFBundleIdentifier" $InfoPlistPath
#     ${PLISTBUDDY} -c "Set :CFBundleDisplayName $CFBundleDisplayName" $InfoPlistPath

#     ${PLISTBUDDY} -c "Set :FacebookAppID $FacebookAppID" $InfoPlistPath
#     ${PLISTBUDDY} -c "Set :FacebookDisplayName $FacebookDisplayName" $InfoPlistPath


#     ${PLISTBUDDY} -c "Delete CFBundleURLTypes" $InfoPlistPath
#     ${PLISTBUDDY} -c "Add CFBundleURLTypes array" $InfoPlistPath

#     ${PLISTBUDDY} -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" $InfoPlistPath
#     ${PLISTBUDDY} -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string $FacebookBundleURLSchemes" $InfoPlistPath
#     ${PLISTBUDDY} -c "Add :CFBundleURLTypes:1:CFBundleTypeRole string Editor" $InfoPlistPath

#     ${PLISTBUDDY} -c "Add :CFBundleURLTypes:1:CFBundleURLSchemes array" $InfoPlistPath
#     ${PLISTBUDDY} -c "Add :CFBundleURLTypes:1:CFBundleURLSchemes:0 string $GoogleBundleURLSchemes" $InfoPlistPath
# elif [ "$toBuildPlateform" = "appleTv" ]
# then
#     run_platform="appletvos"
#     SchemeName="AppCMS_tvOS"
#     #TODO::Update all resources

#     postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "No ERROR" "Downloading the App Assets" 10 false 0
#     #Downloading Assests and Copying into the Schema Folder
#     aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/AppIcon.appiconset $copyAssetsPath --recursive

#     postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "No ERROR" "Downloading the Build Resources" 15 false 0
#     aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/CastingImageAssets $copyCastPath --recursive

#     postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "No ERROR" "Downloading the Image Resources and Assets" 20 false 0
#     aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/Resources $copySpashPath --recursive

#     InfoPlistPath="$PROJECT_DIR_PATH/$SchemeName/Info.plist"
#     $FacebookBundleURLSchemes="fb227991737252697"
#     $GoogleBundleURLSchemes="gb227991737252697"
#     $FacebookDisplayName=$CFBundleDisplayName
    
#     #------------------Update:Info-plist--------------------------#
#     ${PLISTBUDDY} -c "Set :CFBundleShortVersionString $CFBundleShortVersionString" $InfoPlistPath
#     ${PLISTBUDDY} -c "Set :CFBundleIdentifier $CFBundleIdentifier" $InfoPlistPath
#     ${PLISTBUDDY} -c "Set :CFBundleDisplayName $CFBundleDisplayName" $InfoPlistPath
# else
#     run_platform="ios"
#     SchemeName="AppCMS"
#     echo 'Need to handle for other plateform'
# fi


# SiteConfigPath="$PROJECT_DIR_PATH/Snagfilms/Resources/Plist/SiteConfig.plist"
# AirshipConfigPath="$PROJECT_DIR_PATH/Snagfilms/Resources/Plist/AirshipConfig.plist"
# PojectResourcesPath="$PROJECT_DIR_PATH/Snagfilms"
# EntitlementsPlistPath="$PROJECT_DIR_PATH/Snagfilms/Snagfilms.entitlements"

# #Update:Site-plist
# ${PLISTBUDDY} -c "Set :SiteId $SiteId" $SiteConfigPath
# ${PLISTBUDDY} -c "Set :UIJsonBaseUrl $UIJsonBaseUrl" $SiteConfigPath
# ${PLISTBUDDY} -c "Set :AppSecretKey $AppSecretKey" $SiteConfigPath


# ${PLISTBUDDY} -c "Delete GoogleClientId" $SiteConfigPath
# if [ ! -z "$GoogleClientId" -a "$GoogleClientId" != " " ]; then
#     ${PLISTBUDDY} -c "Add :GoogleClientId string $GoogleClientId" $SiteConfigPath
# fi

# if [ "$toBuildPlateform" = "ios" ]
# then
#     #Apptentive
#     ${PLISTBUDDY} -c "Set :'Apptentive Key' $ApptentiveKey" $SiteConfigPath
#     ${PLISTBUDDY} -c "Set :'Apptentive AppKey' $ApptentiveAppKey" $SiteConfigPath
#     ${PLISTBUDDY} -c "Set :'Apptentive AppSignature' $ApptentiveAppSignature" $SiteConfigPath
#     ${PLISTBUDDY} -c "Set :'Apptentive AppId' $ApptentiveAppId" $SiteConfigPath

#     #AppFlyer
#     ${PLISTBUDDY} -c "Delete 'AppFlyer Key'" $SiteConfigPath
#     if [ ! -z "$AppFlyerAppKey" -a "$AppFlyerAppKey" != " " ]; then
#         ${PLISTBUDDY} -c "Add :'AppFlyer Key' string $AppFlyerAppKey" $SiteConfigPath
#     fi

#     ${PLISTBUDDY} -c "Delete 'AppFlyer APPID'" $SiteConfigPath
#     if [ ! -z "$AppFlyerAPPID" -a "$AppFlyerAPPID" != " " ]; then
#     ${PLISTBUDDY} -c "Add :'AppFlyer APPID' string $AppFlyerAPPID" $SiteConfigPath
#     fi

#     #AirshipConfigPath
#     ${PLISTBUDDY} -c "Set :DEVELOPMENT_APP_KEY $UrbanAirshipDevKey" $AirshipConfigPath
#     ${PLISTBUDDY} -c "Set :DEVELOPMENT_APP_SECRET $UrbanAirshipDevSecret" $AirshipConfigPath
#     ${PLISTBUDDY} -c "Set :PRODUCTION_APP_KEY $UrbanAirshipProdKey" $AirshipConfigPath
#     ${PLISTBUDDY} -c "Set :PRODUCTION_APP_SECRET $UrbanAirshipProdSecret" $AirshipConfigPath

#     #$EntitlementsPlistPath
#     ${PLISTBUDDY} -c "Delete com.apple.developer.associated-domains" $EntitlementsPlistPath
#     ${PLISTBUDDY} -c "Add com.apple.developer.associated-domains array" $EntitlementsPlistPath
#     ${PLISTBUDDY} -c "Add :com.apple.developer.associated-domains:0 string $AssociatedDomains01" $EntitlementsPlistPath
#     ${PLISTBUDDY} -c "Add :com.apple.developer.associated-domains:1 string $AssociatedDomains02" $EntitlementsPlistPath
# fi



# #Remove all archive data
echo "Cleanup temporary files..."
rm -rf "$PROJECT_DIR_PATH/fastlane/metadata"
rm -rf "$PROJECT_DIR_PATH/fastlane/screenshots"
rm -rf "$PROJECT_DIR_PATH/fastlane/Deliverfile"
rm -rf "$PROJECT_DIR_PATH/fastlane/builds" *
rm -rf "$PROJECT_DIR_PATH/fastlane/Certificates" *

echo "InfoPlist updated"

#Adding Username and Password to the Keychain
fastlane fastlane-credentials add --username piyushaggarwal.incedo@gmail.com --password Alexa@123

fastlane deliver init --username piyushaggarwal.incedo@gmail.com --app_identifier "com.piyush.automate" --team_id 691013
IS_APP_ONPLAYSTORE="$?"
fastlane appcmsCreateBuild appname:Snagfilmstesting bundleIdentifier:com.snagfilms.snagfilmsformobile devTeamId:AC3B332EWB buildId:645 posturl:http://staging4.partners.viewlift.com/snagfilmstest1/appleTv/appcms/build/status username:piyushaggarwal.incedo@gmail.com password:Alexa@123 baseResultPath:$PROJECT_DIR_PATH scheme:Snagfilms isAppOnStore:$IS_APP_ONPLAYSTORE appVersion:$CFBundleShortVersionString platform:$toBuildPlatform ituneTeamId:691013


#Install profile

# #postBuildStatus "$BUILD_ID" "$POST_URL" 'METADATA_CREATED' ""

# #Examples
# #fastlane appcmsbuild appname:Snagfilms bundleIdentifier:com.snagfilms.snagfilmsforipad teamid:V743M68NY7 buildid:645 posturl:http://staging4.partners.viewlift.com/snagfilmstest1/appleTv/appcms/build/status username:deepak.sahu@incedoinc.com password:Incedo@2017 resultPath:/Users/deepaksahu/Documents/Projects/Projects/Mobility/ViewLift/fastlane-project/fastlanedemo/iOS/AppCMS/fastlane/products/Snagfilms/ scheme:AppCMS_tvOS buildType:beta provisioning_profile_name:tvOS_SnagFilms_AppStore
# #fastlane appcmsbuild appname:Snagfilms bundleIdentifier:com.snagfilms.snagfilmsforipad teamid:V743M68NY7 buildid:641 posturl:http://staging4.partners.viewlift.com/snagfilmstest1/ios/appcms/build/status username:deepak.sahu@incedoinc.com password:Incedo@2017 resultPath:/Users/deepaksahu/Documents/Projects/Projects/Mobility/ViewLift/fastlane-project/fastlanedemo/iOS/AppCMS/fastlane/products/Snagfilms/ scheme:AppCMS buildType:beta provisioning_profile_name:SnagFilms_AppStore_Provisioning
# #Debug|Release
# #lane name should be appcmsbuild or developmentbuild
# echo "fastlane $run_platform developmentbuild appname:"$CFBundleDisplayName" bundleIdentifier:"$CFBundleIdentifier" team_id:"$team_id" devteamid:"$DevTeamId" buildid:"$BUILD_ID" posturl:"$POST_URL" username:"$username" password:"$password" resultPath:"$FastlaneResultPath" scheme:"$SchemeName" buildType:"$BuildType" provisioning_profile_name:"$DistibutionProfileName""
# fastlane $run_platform developmentbuild appname:"$CFBundleDisplayName" bundleIdentifier:"$CFBundleIdentifier" team_id:"$team_id" devteamid:"$DevTeamId" buildid:"$BUILD_ID" posturl:"$POST_URL" username:"$username" password:"$password" resultPath:"$FastlaneResultPath" scheme:"$SchemeName" buildType:"$BuildType" provisioning_profile_name:"$DistibutionProfileName"


# #Remove all archive data
# echo "Cleanup temporary files..."
# #rm -rf $FastlaneResultPath
# #rm -rf $FastlaneResultPath"/DerivedData"
# #rm -rf $FastlaneResultPath"/build"
# #rm -rf $FastlaneResultPath"/screenshots"
# #rm -rf $FastlaneResultPath"/metadata"







