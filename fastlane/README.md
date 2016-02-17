fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios initApp
```
fastlane ios initApp
```
Creating an app, code signing certificate and provisioning profiles, PN certs
### ios beta
```
fastlane ios beta
```
Submit a new Beta Build to Apple TestFlight

This will also make sure the profile is up to date
### ios full_deploy
```
fastlane ios full_deploy
```
Deploy version to the App Store along with all metadata and screenshots
### ios deploy
```
fastlane ios deploy
```
Deploy a new version to the App Store without updating metadata or screenshots
### ios build
```
fastlane ios build
```
Test and create .ipa
### ios deliver
```
fastlane ios deliver
```
Deliver app
### ios screenshot
```
fastlane ios screenshot
```
Making screenshots for supported devices
### ios pilot
```
fastlane ios pilot
```
Add new tester and sent application to TestFlight testers
### ios test
```
fastlane ios test
```
Run tests

----

This README.md is auto-generated and will be re-generated every time to run [fastlane](https://fastlane.tools)
More information about fastlane can be found on [https://fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [GitHub](https://github.com/fastlane/fastlane)