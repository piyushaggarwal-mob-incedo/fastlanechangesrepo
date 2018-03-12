fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```
Runs all the tests
### ios iosMobileBuildCreation
```
fastlane ios iosMobileBuildCreation
```
Deploy a new version to the App Store- with custom
### ios slackSendMessage
```
fastlane ios slackSendMessage
```
Deploy a new version to the App Store

Send Messages on Slack
### ios buildFailedLane
```
fastlane ios buildFailedLane
```
Send Failed Messages on Slack

----

## appletvos
### appletvos test
```
fastlane appletvos test
```
Runs all the tests
### appletvos appcmsbuild
```
fastlane appletvos appcmsbuild
```
Deploy a new version to the App Store- with custom
### appletvos developmentbuild
```
fastlane appletvos developmentbuild
```
Deploy a new version to the App Store

Deploy a new version to the developer with custom

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
