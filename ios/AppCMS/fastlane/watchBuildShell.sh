#!/bin/bash

echo "WATCH BUILD SHELL"

echo $1
echo $2
echo $3
echo $4
echo $5

echo "WATCH BUILD SHELL"


PLISTBUDDY="/usr/libexec/PlistBuddy"
InfoPlistPath="./watchbuilds.plist"

${PLISTBUDDY} -c "Set :JobBuildId ${1}" ${InfoPlistPath}
${PLISTBUDDY} -c "Set :posturl ${2}" ${InfoPlistPath}
${PLISTBUDDY} -c "Set :bundleIdentifier ${3}" ${InfoPlistPath}
${PLISTBUDDY} -c "Set :appBuildNumber ${4}" ${InfoPlistPath}
${PLISTBUDDY} -c "Set :username ${5}" ${InfoPlistPath}


open ./watchBuildStatus


