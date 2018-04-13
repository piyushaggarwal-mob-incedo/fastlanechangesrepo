#!/bin/bash
#!/usr/local/bin/
#!/usr/bin/env
#!/usr/bin/ruby

PLISTBUDDY="/usr/libexec/PlistBuddy"
InfoPlistPath="./Desktop/fastlane-qa/Job.plist"
while true
do
	echo $PWD
	${PLISTBUDDY} -c "Set :JobExecutionInProgress false" ${InfoPlistPath}

    python ./Desktop/fastlane-qa/flJobManager.py

    echo "Press [CTRL+C] to stop.."
    sleep 10
done
