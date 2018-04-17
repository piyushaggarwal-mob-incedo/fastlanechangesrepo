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

## appletvosBuild
### appletvosBuild test
```
fastlane appletvosBuild test
```
Runs all the tests
### appletvosBuild appleTvStoreBuild
```
fastlane appletvosBuild appleTvStoreBuild
```
Deploy a new version to the App Store- with custom
### appletvosBuild appleTvbuild
```
fastlane appletvosBuild appleTvbuild
```
Deploy a new version to the developer with custom
### appletvosBuild slackSendMessage
```
fastlane appletvosBuild slackSendMessage
```
Deploy a new version to the App Store

Send Messages on Slack
### appletvosBuild buildFailedLane
```
fastlane appletvosBuild buildFailedLane
```
Send Failed Messages on Slack

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
