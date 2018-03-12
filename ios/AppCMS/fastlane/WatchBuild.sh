#!/bin/sh
#!/bin/bash
#Need to modify runner.rb and remove notifier code
#/Library/Ruby/Gems/2.0.0/gems/watchbuild-0.2.0/lib/watchbuild/runner.rb

echo "************ WatchBuild ************"
now="$(date)"
printf "WatchBuild::Current date and time %s\n" "$now [Date:$(date +'%d/%m/%Y')]"

#ACTION "+options[:buildid] + " "+ options[:posturl] + " "+ options[:bundleIdentifier] + " "+ options[:username] + " " + options[:password]
fastlane --version
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
echo $PWD

action=$1
buildid=$2
posturl=$3
bundleIdentifier=$4
username=$5
password=$6

./WatchBuildManager $1 $2 $3 $4 $5 $6

#result=$(watchbuild -a com.snagfilms.snagfilmsforipad -u deepak.sahu@incedoinc.com --sample_only_once true 2>/dev/null)
#echo $result
