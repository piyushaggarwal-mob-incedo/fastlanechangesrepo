#!/bin/bash

PLISTBUDDY="/usr/libexec/PlistBuddy"

postBuildStatus(){ #buildid, posturl, status, errormsg
    BODY_DATA="{\"buildId\":$1,\"status\":\"$3\",\"errorMessage\":\"$4\"}"
    BODY_DATA="{\"buildId\":$1,\"status\":\"$3\",\"errorMessage\":\"$4\",\"message\":\"$5\",\"percentComplete\":$6,\"buildVersion\":\"$7\"}"
    echo "\n**********BUILD_STATUS_UPDATE**********\nPOST_URL=$2\nBODY_DATA=["$BODY_DATA"]\n---------------------------------------"
    curl -H 'Content-Type: application/json' -X POST -d "$BODY_DATA" $2
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
bundleId)           CFBundleIdentifier=${VALUE} ;;
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
facebookId)             FacebookAppID=${VALUE} ;;
bundleURLSchemes)       FacebookBundleURLSchemes=${VALUE} ;;
facebookDisplayName)    FacebookDisplayName=${VALUE} ;;

#google
bundleURLSchemesGoogle) GoogleBundleURLSchemes=${VALUE} ;;
googleClientId)         GoogleClientId=${VALUE} ;;

resourcePath)           ResourceURLPath=${VALUE} ;;

#Post Url for Sending the Post Status
POST_URL)               POST_URL=${VALUE} ;;
#Site Id of the Application
#Build Id of the Build to be generated
BUILD_ID)               BUILD_ID=${VALUE} ;;

associatedDomain01)     AssociatedDomain=${VALUE} ;;

ituneTeamId) ituneTeamId=${VALUE} ;;
appleTeamId)    devTeamId=${VALUE} ;;

isMultipleTeams)    isMultipleTeams=${VALUE} ;;

myemailid)    myEmailId=${VALUE} ;;
bukcet_name)    bucketName=${VALUE} ;;
marketingUrl)    marketingUrl=${VALUE} ;;
supportUrl)      supportUrl=${VALUE} ;;
copyright)  copyRigthText=${VALUE} ;;
slackWebHook)  slackWebHookUrl=${VALUE} ;;
description)  myAppDescription=${VALUE} ;;
releaseNotes)  appReleaseNotes=${VALUE} ;;
primaryCategory)  primaryCategory=${VALUE} ;;

appReviewDemoUser)  appReviewDemoUser=${VALUE} ;;
appReviewDemoPassword)  appReviewDemoPassword=${VALUE} ;;
appReviewFirstName)  appReviewFirstName=${VALUE} ;;
appReviewLastName)  appReviewLastName=${VALUE} ;;
appReviewPhoneNumber)  appReviewPhoneNumber=${VALUE} ;;
appReviewEmail)  appReviewEmail=${VALUE} ;;
appReviewNotes)  appReviewNotes=${VALUE} ;;

releaseType)  releaseType=${VALUE} ;;
rating)  rating=${VALUE} ;;

SiteName)     SiteName=${VALUE} ;;
appShortName)  appShortName=${VALUE} ;;

# itunesConnectUserName)     itunesConnectUserName=${VALUE} ;;
# itunesConnectPassword)  itunesConnectPassword=${VALUE} ;;

*)
esac
done

itunesConnectUserName="piyushaggarwal.incedo@gmail.com"
itunesConnectPassword="Alexa@123"

MY_POST_URL="${POST_URL}/${SiteName}/ios/appcms/build/status"
MY_UPLOAD_URL="${POST_URL}/${SiteName}/appcms/ios/build/apk/link"


# fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> IOS BUILD SUCCESSFULLY STARTED. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform" mySlackURL:$slackWebHookUrl
fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> IOS BUILD SUCCESSFULLY STARTED. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform"



postBuildStatus ${BUILD_ID} $MY_POST_URL "STARTED" "No ERROR" "Build Process Initiated Successfully" 5  0

sleep 10

echo "PROJECT_DIR_PATH = $projectPath"
echo "FastlaneResultPath = $projectPath/fastlane"

echo "BuildType = $BuildType"
echo "CFBundleDisplayName = $CFBundleDisplayName"
echo "CFBundleShortVersionString = $CFBundleShortVersionString"
echo "UIJsonBaseUrl = $UIJsonBaseUrl"
echo "CFBundleIdentifier = $CFBundleIdentifier"
echo "SiteId = $SiteId"


#AppSecretKey
echo "AppSecretKey = $AppSecretKey"

echo "ResourceURLPath = $ResourceURLPath"

echo "DistibutionProfileName = $DistibutionProfileName"
echo "AssociatedDomain = $AssociatedDomain"
echo "POST_URL=$POST_URL"

echo "AppleDevTeamId = $devTeamId"
echo "iTunes_team_id=$ituneTeamId"

echo "appstoreName=$appstoreName"

echo "iTunesUsername = $itunesConnectUserName"
echo "iTunesPassword = $itunesConnectPassword"


echo "POST_URL = $POST_URL"
echo "SITE_ID = $SITE_ID"
echo "BUILD_ID = $BUILD_ID"
echo "iTuneConnectTeamId = $ituneTeamId"
echo "devTeamId = $devTeamId"
echo "myemailid = $myEmailId"
echo "marketingUrl = $marketingUrl"
echo "supportUrl = $supportUrl"
echo "copyright = $copyRigthText"
echo "slackWebHook = $slackWebHookUrl"
echo "appDescription = $myAppDescription"
echo "appReleaseNotes = $appReleaseNotes"
echo "primaryCategory = $primaryCategory"
echo "appReviewDemoUser = $appReviewDemoUser"
echo "appReviewDemoPassword = $appReviewDemoPassword"
echo "appReviewFirstName = $appReviewFirstName"
echo "appReviewLastName = $appReviewLastName"
echo "appReviewPhoneNumber = $appReviewPhoneNumber"
echo "appReviewEmail = $appReviewEmail"
echo "appReviewNotes = $appReviewNotes"

echo "SiteName = $SiteName"
echo "appShortName = $appShortName"
echo "rating = $rating"

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

AssociatedDomains01="applinks:$AssociatedDomain"
AssociatedDomains02="applinks:www.$AssociatedDomain"

#Configuration Values
ProjectName="Snagfilms"
run_platform="$toBuildPlatform"
SchemeName="Snagfilms"


echo "###################################################################################################################"
echo "BUILD PROCESS STARTED"
echo "####################################################################################################################"



if [ "$toBuildPlatform" = "ios" ]
then

    run_platform="ios"
    SchemeName="Snagfilms"

    #Downloading Resources

    #------------------Update:Resources--------------------------#
    ##Replace all Resources
    copyAssetsPath="$PROJECT_DIR_PATH/Snagfilms/Assets.xcassets/AppIcon.appiconset"
    copyCastPath="$PROJECT_DIR_PATH/Snagfilms/Resources/Images/CastingImageAssets"
    copySpashPath="$PROJECT_DIR_PATH/Snagfilms/Resources/Images"
    ratingsPath="$PROJECT_DIR_PATH/fastlane"


    #Downloading Assests and Copying into the Schema Folder
    # fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> DOWNLOADING RESOURCES FOR THE BUILD. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform" mySlackURL:$slackWebHookUrl
    fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> DOWNLOADING RESOURCES FOR THE BUILD. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform"

    postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "'NO ERROR'" "Downloading Resources Required For Generating Build" 10  0
    aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/AppIcon.appiconset $copyAssetsPath --recursive

    # fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> DOWNLOADING ASSETS FOR BUILD GENERATION. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform" mySlackURL:$slackWebHookUrl
    fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> DOWNLOADING ASSETS FOR BUILD GENERATION. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform"

    postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "'No ERROR'" "Downloading Assets" 12  0
    aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/CastingImageAssets $copyCastPath --recursive

    fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> DOWNLOADING IMAGES FOR BUILD GENERATION. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform"
    # fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> DOWNLOADING IMAGES FOR BUILD GENERATION. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform" mySlackURL:$slackWebHookUrl

    postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "'No ERROR'" "Downloading Images and App Icon Assets For Build" 15  0
    aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/Resources $copySpashPath --recursive


    fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> CONFIGURING BUILD AND SETTING SDK KEYS. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform"
    # fastlane ios slackSendMessage my_slack_msg:"${CFBundleDisplayName} -> CONFIGURING BUILD AND SETTING SDK KEYS. BUILD-ID -> ${BUILD_ID}. VERSION-NUMBER -> ${CFBundleShortVersionString}. BUILD TRIGGERED BY --> ${myEmailId}" my_user_name:"Viewlift Build Automation Platform" mySlackURL:$slackWebHookUrl

    postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Configuring the Build and setting the Sdk and their Keys" 18  0
    sleep 10

    InfoPlistPath="$PROJECT_DIR_PATH/$SchemeName/Info.plist"
    # $FacebookBundleURLSchemes="fb227991737252697"
    # $GoogleBundleURLSchemes="gb227991737252697"
    # $FacebookDisplayName=$CFBundleDisplayName

    #------------------Update:Info-plist--------------------------#

    postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Fetching and Saving the Google Services Plist" 20  0
    sleep 10


    postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Configuring the Build Version of the Application" 25  

    sleep 10
    ${PLISTBUDDY} -c "Set :CFBundleShortVersionString $CFBundleShortVersionString" $InfoPlistPath
    postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Configuring the Bundle Identifier of the Application" 25  
    sleep 10
    

    ${PLISTBUDDY} -c "Set :CFBundleIdentifier $CFBundleIdentifier" $InfoPlistPath

    ${PLISTBUDDY} -c "Set :CFBundleDisplayName $CFBundleDisplayName" $InfoPlistPath


    postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Configuring the Facebook Library for Build" 27  0
    

    # ${PLISTBUDDY} -c "Set :FacebookAppID $FacebookAppID" $InfoPlistPath
    # ${PLISTBUDDY} -c "Set :FacebookDisplayName $FacebookDisplayName" $InfoPlistPath


    # ${PLISTBUDDY} -c "Delete CFBundleURLTypes" $InfoPlistPath
    # ${PLISTBUDDY} -c "Add CFBundleURLTypes array" $InfoPlistPath

    # ${PLISTBUDDY} -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" $InfoPlistPath
    # ${PLISTBUDDY} -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string $FacebookBundleURLSchemes" $InfoPlistPath
    # ${PLISTBUDDY} -c "Add :CFBundleURLTypes:1:CFBundleTypeRole string Editor" $InfoPlistPath

    # ${PLISTBUDDY} -c "Add :CFBundleURLTypes:1:CFBundleURLSchemes array" $InfoPlistPath
    # ${PLISTBUDDY} -c "Add :CFBundleURLTypes:1:CFBundleURLSchemes:0 string $GoogleBundleURLSchemes" $InfoPlistPath
elif [ "$toBuildPlateform" = "appleTv" ]
then
    run_platform="appletvos"
    SchemeName="AppCMS_tvOS"
    #TODO::Update all resources

    postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "No ERROR" "Downloading the App Assets" 10 false 0
    #Downloading Assests and Copying into the Schema Folder
    aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/AppIcon.appiconset $copyAssetsPath --recursive

    postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "No ERROR" "Downloading the Build Resources" 15 false 0
    aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/CastingImageAssets $copyCastPath --recursive

    postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "No ERROR" "Downloading the Image Resources and Assets" 20 false 0
    aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/resource/Resources $copySpashPath --recursive

    postBuildStatus ${BUILD_ID} $MY_POST_URL "DOWNLOADING_RESOURCES" "No ERROR" "Downloading the Application rating" 22 false 0
    aws s3 cp s3://appcms-config/$SiteId/build/$toBuildPlatform/itunes_rating_config.json $ratingsPath


    InfoPlistPath="$PROJECT_DIR_PATH/$SchemeName/Info.plist"
    $FacebookBundleURLSchemes="fb227991737252697"
    $GoogleBundleURLSchemes="gb227991737252697"
    $FacebookDisplayName=$CFBundleDisplayName
    
    #------------------Update:Info-plist--------------------------#
    ${PLISTBUDDY} -c "Set :CFBundleShortVersionString $CFBundleShortVersionString" $InfoPlistPath
    ${PLISTBUDDY} -c "Set :CFBundleIdentifier $CFBundleIdentifier" $InfoPlistPath
    ${PLISTBUDDY} -c "Set :CFBundleDisplayName $CFBundleDisplayName" $InfoPlistPath
else
    run_platform="ios"
    SchemeName="AppCMS"
    echo 'Need to handle for other plateform'
fi


SiteConfigPath="$PROJECT_DIR_PATH/Snagfilms/Resources/Plist/SiteConfig.plist"
AirshipConfigPath="$PROJECT_DIR_PATH/Snagfilms/Resources/Plist/AirshipConfig.plist"
PojectResourcesPath="$PROJECT_DIR_PATH/Snagfilms"
EntitlementsPlistPath="$PROJECT_DIR_PATH/Snagfilms/Snagfilms.entitlements"

#Update:Site-plist
${PLISTBUDDY} -c "Set :SiteId $SiteId" $SiteConfigPath
# ${PLISTBUDDY} -c "Set :UIJsonBaseUrl $UIJsonBaseUrl" $SiteConfigPath
# ${PLISTBUDDY} -c "Set :AppSecretKey $AppSecretKey" $SiteConfigPath


${PLISTBUDDY} -c "Delete GoogleClientId" $SiteConfigPath
if [ ! -z "$GoogleClientId" -a "$GoogleClientId" != " " ]; then
    ${PLISTBUDDY} -c "Add :GoogleClientId string $GoogleClientId" $SiteConfigPath
fi


if [ "$toBuildPlateform" = "ios" ]
then
#     #Apptentive
      postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Configuring the Apptentive Library for Build" 30  0
      sleep 10
#     ${PLISTBUDDY} -c "Set :'Apptentive Key' $ApptentiveKey" $SiteConfigPath
#     ${PLISTBUDDY} -c "Set :'Apptentive AppKey' $ApptentiveAppKey" $SiteConfigPath
#     ${PLISTBUDDY} -c "Set :'Apptentive AppSignature' $ApptentiveAppSignature" $SiteConfigPath
#     ${PLISTBUDDY} -c "Set :'Apptentive AppId' $ApptentiveAppId" $SiteConfigPath

#     #AppFlyer
      postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Configuring the AppFlyerAPPID Library for Build" 33  0
      sleep 10
#     ${PLISTBUDDY} -c "Delete 'AppFlyer Key'" $SiteConfigPath
#     if [ ! -z "$AppFlyerAppKey" -a "$AppFlyerAppKey" != " " ]; then
#         ${PLISTBUDDY} -c "Add :'AppFlyer Key' string $AppFlyerAppKey" $SiteConfigPath
#     fi

#     ${PLISTBUDDY} -c "Delete 'AppFlyer APPID'" $SiteConfigPath
#     if [ ! -z "$AppFlyerAPPID" -a "$AppFlyerAPPID" != " " ]; then
#     ${PLISTBUDDY} -c "Add :'AppFlyer APPID' string $AppFlyerAPPID" $SiteConfigPath
#     fi

#     #AirshipConfigPath
      postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Configuring the UrbanAirship Library for Build" 35  0
      sleep 10

#     ${PLISTBUDDY} -c "Set :DEVELOPMENT_APP_KEY $UrbanAirshipDevKey" $AirshipConfigPath
#     ${PLISTBUDDY} -c "Set :DEVELOPMENT_APP_SECRET $UrbanAirshipDevSecret" $AirshipConfigPath
#     ${PLISTBUDDY} -c "Set :PRODUCTION_APP_KEY $UrbanAirshipProdKey" $AirshipConfigPath
#     ${PLISTBUDDY} -c "Set :PRODUCTION_APP_SECRET $UrbanAirshipProdSecret" $AirshipConfigPath
      postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "'No ERROR'" "Configuring the Entitlements Path For The Build" 37  0

#     #$EntitlementsPlistPath
#     ${PLISTBUDDY} -c "Delete com.apple.developer.associated-domains" $EntitlementsPlistPath
#     ${PLISTBUDDY} -c "Add com.apple.developer.associated-domains array" $EntitlementsPlistPath
#     ${PLISTBUDDY} -c "Add :com.apple.developer.associated-domains:0 string $AssociatedDomains01" $EntitlementsPlistPath
#     ${PLISTBUDDY} -c "Add :com.apple.developer.associated-domains:1 string $AssociatedDomains02" $EntitlementsPlistPath
fi




#This File is Deleted as it is of No use
rm -rf "$PROJECT_DIR_PATH/fastlane/Deliverfile"
echo "Cleanup temporary files..."
rm -rf "$PROJECT_DIR_PATH/fastlane/builds"
rm -rf "$PROJECT_DIR_PATH/fastlane/Certificates"



InfoPlistPath="$PROJECT_DIR_PATH/Snagfilms/Info.plist"

#------------------Update:Info-plist--------------------------#
${PLISTBUDDY} -c "Set :CFBundleShortVersionString $CFBundleShortVersionString" $InfoPlistPath
${PLISTBUDDY} -c "Set :CFBundleIdentifier $CFBundleIdentifier" $InfoPlistPath


export FASTLANE_USER=$itunesConnectUserName
export FASTLANE_PASSWORD=$itunesConnectPassword


#Creating Certficates and Build Foler
mkdir "$PROJECT_DIR_PATH/fastlane/Certificates"
mkdir "$PROJECT_DIR_PATH/fastlane/builds"

postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "No ERROR" "Connecting to the Itunes and Checking if Already App Exists" 42  0

fastlane deliver init --team_id $ituneTeamId --username $itunesConnectUserName --app_identifier $CFBundleIdentifier --dev_portal_team_id $devTeamId

IS_APP_ONPLAYSTORE="$?"

#Configuring Metadata for the build

#Decoding the File for Google Services Plist.
base64 --decode ./crfile.txt > ./ogleService-Info.plist

appIconPath="$PROJECT_DIR_PATH/Snagfilms/Assets.xcassets/AppIcon.appiconset/AppStoreIcon-1024.png"

echo $marketingUrl > ./fastlane/metadata/en-US/marketing_url.txt
echo $supportUrl > ./fastlane/metadata/en-US/support_url.txt
echo $myAppDescription > ./fastlane/metadata/en-US/description.txt
echo $CFBundleDisplayName > ./fastlane/metadata/en-US/name.txt
echo $myAppDescription > ./fastlane/metadata/en-US/keywords.txt
echo $supportUrl > ./fastlane/metadata/en-US/privacy_url.txt
echo $appReleaseNotes > ./fastlane/metadata/en-US/release_notes.txt


echo $copyright > ./fastlane/metadata/copyright.txt
echo $primaryCategory > ./fastlane/metadata/primary_category.txt
echo $primaryCategory > ./fastlane/metadata/secondary_category.txt

echo $appReviewDemoUser > ./fastlane/metadata/review_information/demo_user.txt
echo $appReviewDemoPassword > ./fastlane/metadata/review_information/demo_password.txt
echo $appReviewFirstName > ./fastlane/metadata/review_information/first_name.txt
echo $appReviewLastName > ./fastlane/metadata/review_information/last_name.txt
echo $appReviewPhoneNumber > ./fastlane/metadata/review_information/phone_number.txt
echo $appReviewEmail > ./fastlane/metadata/review_information/email_address.txt
echo $appReviewNotes > ./fastlane/metadata/review_information/notes.txt


if [ "$IS_APP_ONPLAYSTORE" -eq "0" ]
        then
        echo "App is Present on App Store"
        postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "No ERROR" "Connecting to the Itunes Connect and Updating your App" 45  0
        sleep 20

else
        echo "App is not Present on Play Store"
        postBuildStatus ${BUILD_ID} $MY_POST_URL "CONFIGURING_BUILD" "No ERROR" "Creating your App on the Itunes Connect and Apple Developer Account" 45  0
fi


echo $IS_APP_ONPLAYSTORE

fastlane ios iosMobileBuildCreation appname:$CFBundleDisplayName skuName:$appShortName bundleIdentifier:$CFBundleIdentifier devTeamId:$devTeamId buildId:${BUILD_ID} posturl:$MY_POST_URL username:piyushaggarwal.incedo@gmail.com password:Alexa@123 baseResultPath:$PROJECT_DIR_PATH scheme:Snagfilms_iOS isAppOnStore:$IS_APP_ONPLAYSTORE appVersion:$CFBundleShortVersionString platform:$toBuildPlatform ituneTeamId:$ituneTeamId appIconPath:$appIconPath myEmailId:${myEmailId} mySiteId:${SiteId} myUploadUrl:${MY_UPLOAD_URL} ratingPath:$rating myItunesUsername:$itunesConnectUserName slackWebHookUrl:$slackWebHookUrl 

IS_SUCCESFULLY_CREATED_UPLOADED="$?"

if [ "$IS_SUCCESFULLY_CREATED_UPLOADED" -eq "0" ]
        then
        echo "SUCCESSFULLY BUILD"
        # postBuildStatus ${BUILD_ID} $MY_POST_URL "FAILED_BUILD_ERROR" "Unexpected Error Occurred" " " 45  0
else
        echo "SUCCESSFULLY BUILD"
        postBuildStatus ${BUILD_ID} $MY_POST_URL "FAILED_BUILD_ERROR" "Unexpected Error Occurred" " " 45  0
fi








