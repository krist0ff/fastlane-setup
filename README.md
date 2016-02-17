# Fastlane example setup (X8 Ltd.)


## Introduction

During lifetime of iOS application there are dozens of tasks not related to normal project work that are required of programmer. 
At the start, one needs to create application in Developer Program, set it up in iTunesConnect, create all necessary provisioning profiles and managed them when some change is required (i.e. client wishes to set up push notifications for the app), later on there is need to 
All those task takes time and are repeadable for every iOS application. That's enough reason to try to automate them. 

Until recently there were few tools that were trying to solve this problem, but none of them get it right. 


Let's list the thing that we need to do to release iOS application (besides coding it, of course ;)) :

### Preparations for development

* create App Id
* create Developer Certificate (optional) - 5 steps
* create Distribution Certificate - 5 steps
* create Development Provisiong Profile (optional) - 6 steps
* create Ad Hoc Provisiong Profile (optional) - 6 steps
* create AppStore Provisiong Profile - 6 steps
* create Push Notifications (development)
* create Push Norifications (AppStore)
* generate .pem files for backedn site for Push Notifications

Additionaly, bare in mind that each time you want to add device you need to regenerate Development PP and Ad Hoc PP.
Also, all of the certificates have validity period, so they need to be regenerated when expired.

### App distributions to testers

Nowadays, in the world of iOS7+ applications we can rely fully on Apple solutions for deploying our application for testers. Solution like HockeyApp / Fabrics are no longer required, but can be nice additional for internal testers in the organization.

To enable TestFlight testing first we need to:

* create App in iTunesConnect (iTC)
* add internal / external testers
* configure changelog, contact info, test user data
* upload the build 
* wait for processing the build 
* release uploaded build to testers

### AppStore distribution

So far the most tedious task is to prepare application for distribution. If our application is universal and supports more than 1 language, taking screenshots itself can take hours. Not to mention setting up app metadata. To sum up:

* create App in ItunesConnect (iTC)
* fill in metadata for each supported language
* generate all the screenshots for all supported devices for each language (so it can be even to 100 screenshots in some cases)
* setup contact information
* upload and select build
* submit application to the review


## Fastlane to the rescue

Fortunately, there is solution to automate all this manual mess. This requires a whole sets of tools which can communicate with Developer Program, iTunes Connect, manage TestFlight, prepare iOS build, and automate procedure for taking screenshots. Currentyly the best solution which is able to take care of all those tasks is Fastlane. Created by Felix Krause, current employee of Twitter, Fastlane is flexible set of tools written in Ruby which helps iOS Developers to automate most of mentioned tedious tasks.

### Fastlane requirements

To setup Fastlane we need:

* OS X 10.7
* Ruby 2.0 > 
* XCode 7 (for automatic screenshots)

---
**Warning**

Since OSX 10.11, Apple reinforce the security system. Called System Integrity Protection, Apple locks down :

/System
/sbin
/usr (with the exception of /usr/local subdirectory)
To disable this security feature you have to reboot your computer and hold CMD+R at start to boot into OS X Recovery Mode.

Then OS X Utilities > Terminal

Type the command csrutil disable; reboot

Your computer will restart. You will see a confirmation message about the desactivation.

To verified the status of CRS type csrutil status"

**source**: Stackoverflow

---

### Fastlane tools 

Fastlane defines more than 130 actions to be used in it's workflow, but lets just list the most importants toolsets that we'll be using:

* **produce** creates new iOS app in DP and iTC.
* **cert** do-it-all with signing certificates.
* **sigh** do-it-all with provisioning profiles.
* **snapshot** helps to generate localized screenshots for every device based on simple UI Test actions.
* **gym** helps to build and package .ipa
* **deliver** takes care of uploading screenshots, metadata and your apps .ipa files to the iTC and AppStore
* **pem** automatically handles your push notification profiles.


### Fastlane instalation

To install Fastlane, navigate to project main directory, open **Terminal** and type:

	fastlane init
	

You'll be presented with set of questions which helps to setup initial Fastlane configuration. 
Answer **YES** to setting up Snapfile and Deliverfile, type in **app identifier** and your **Apple ID** credentials. Be sure to setup **deliver**, **sigh** and type in **scheme name** to be used by **gym** to build your .ipa.

Don't worry, if you type **NO** to any of this, it can be setup later on independently from each other.

Now you should see new folder *fastlane* with most relevant files being:
* *Appfile* - here you might configure general information about app ID, team name, team ID, etc - this will be used as default by any *lane* defined in *Fastfile*
* *Deliverfile* - stores basic information used by *deliver* to upload your app to iTC
* *Fastfile* - finally, the most important one - here you can define *lanes* which are sets of tools that you can use for different workflows


<<< screenshot should go here >>>



## Automate your workflow
Ok, now we can deal with 3 groups of tasks mentioned before. For each of them we'll create 1 *lane*.

### Preparations for development

For this we need folowing tools:
* **produce** to create app in DP and iTC
* **cert** to generate, save and store signing certificates
* **sigh** to set up provisioning profiles
* **pem** to prepare app for Push Notifications and generate .pem files to be used on the API side.

In theory, **produce** enables us to setup app in both DP and iTC with one command only - this  doesn't work that well if you are using different accounts for DP and iTC which is common case if you are working on more than one project / for more than one company. 
There are example solutions to deal with this issue by defining different set of IDs in **Appfile** but none of those worked for me during initial setup. The workaround is to use **produce** tool twice - first for DP, second for iTC. 

```
produce(
    app_identifier: appId,
    app_name:       appName,
    language:       language,
    app_version:    appVersion,
    sku:            sku,
    team_name:      teamName,
    skip_itc:       true
    )
    produce(
    app_identifier: appId,
    app_name:       appName,
    language:       language,
    app_version:    appVersion,
    sku:            sku,
    team_name:      teamName,
    skip_devcenter: true
    )
```
Next, we need to generate signing certificates and provisioning profiles. **cert** and **sigh** helps to generate one set of those at once, so we need to call **cert** 2 times to set us up for both development and distributions certificates and 3 times to generate profiles for development, ad hoc and AppStore. Additionally, we'll generate everything that is needed for Push Notifications with **pem**.

```
cert(development: true, output_path: certPath)
sigh(development: true, output_path: certPath)
pem(development: true, output_path: certPath)
cert(output_path: certPath)
sigh(adhoc: true, output_path: certPath)
sigh(force: true, output_path: certPath)
pem(output_path: certPath)
```

Notice that first we are using **cert** and **sigh** for development and after this we use **cert** for distribution followed by 2x**sigh** for Ad-Hoc / AppStore. This is not obligatory but I notices some errors when usign **sigh** to generate Ad Hoc / App Store PP, after using **cert** for development. Setting them up in the order like above helps to avoid any problems. 

And that's it - we are good to run this lane and have everything set up for new application. As we are using variables here to setup everything, this can be used with every new application without any problem, just copy it to new Fastfile and run with different set of variables.

So as for now, our first lane looks like this:


```
	desc "Creating an app, code signing certificate and provisioning profiles, PN certs"

  lane :initApp do
    produce(
    app_identifier: appId,
    app_name:       appName,
    language:       language,
    app_version:    appVersion,
    sku:            sku,
    team_name:      teamName,
    skip_itc:       true
    )
    produce(
    app_identifier: appId,
    app_name:       appName,
    language:       language,
    app_version:    appVersion,
    sku:            sku,
    team_name:      teamName,
    skip_devcenter: true
    )
    cert(development: true, output_path: certPath)
    sigh(development: true, output_path: certPath)
    pem(development: true, output_path: certPath)
    cert(output_path: certPath)
    sigh(adhoc: true, output_path: certPath)
    sigh(force: true, output_path: certPath)
    pem(output_path: certPath)
  end

```

### App distributions to testers

To distribute app to testers we need to run tests, make sure that certs are ok, build it and push it to TestFlight.
Our example lane will look like this:


```
  desc "Submit a new Beta Build to Apple TestFlight"
  desc "This will also make sure the profile is up to date"
  lane :beta do
    scan(
      project:  project,
      scheme:   scheme
    )
    sigh
    gym(
      project:          project,
      scheme:           scheme,
      output_directory: './build',
      output_name:      'FLSetup'
      )
      pilot(
        ipa: './build/FLSetup.ipa'
      )
    end
```
In the first step we are using **scan** to run tests - in additional nice raport in .junit + .HTML. 

We use  **sigh** just to make sure that lane will succedd even if provisioning profiles are invalid / expired / some devices were added along the way. 
To build *.ipa* file we'll use **gym** - not too much to explain here, as a result we get properly build and signed file ready to upload to iTC.

Finally, we are using **pilot** to upload binary to iTC and TestFlight. **pilot** allows also to manage testers, so with this tool we can list, add or remove testers for current TF build - this means we really don't need to use iTC portal at all! Adding new tester is as simple as:

	pilot add krodak@x8.io
	
**Pilot** has much more to offer, more options are discussed here: <https://github.com/fastlane/pilot>.

 
### App distributions to testers

Last, but not least, we need to push our application to the AppStore to share its glory with wider userbase. 	
To do this, we first need to prepare all the metadata and screenshots. If our application is universal and supports more than 1 language this may take some time as we'll need at least 50 screenshots.

**Snapshot** comes with help by utilizing new iOS 9 UI Tests framework and enabling to take all the screenshots automaticly with single command. But first we need to set up some simple UI Test to traverse through required screen, i.e.:

```
       
    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

    }

    func testExample() {
        
        let app = XCUIApplication()
        let backButton = app.navigationBars["UIView"].childrenMatchingType(.Button).elementBoundByIndex(0)

        snapshot("00-MainScreen")
        app.buttons["Navigate to VC 1"].tap()
        snapshot("01-VC")

        backButton.tap()
        app.buttons["Navigate to VC 2"].tap()
        snapshot("02-VC")
        backButton.tap()
        app.buttons["Navigate to VC 3"].tap()
        snapshot("03-VC")
        backButton.tap()
        app.buttons["Navigate to VC 4"].tap()
        snapshot("04-VC")
        backButton.tap()

    }

```

We just need to things - **setupSnapshot** to plug in the mechanism and than call **snapshot(*VC name*)** to save current view as screenshot. 
Corresponding fastlane code looks like this:

```
      snapshot(
        scheme:             'flsetup',
        reinstall_app:      true,
        app_identifier:     appId,
        skip_open_summary:  true
      )
```

**Deliver** tool helps with sending .ipa, screenshots and all app metadata. To enable this, the tool creates folders structures to map all metadata elements into simple independent textfiles.
When we are ready, we can connect those 2 tools with **scan**, **sigh** and **gym** to build whole workflow:

```
    desc "Deploy version to the App Store along with all metadata and screenshots"
    lane :full_deploy do
      snapshot(
        scheme:             'flsetup',
        reinstall_app:      true,
        app_identifier:     appId,
        skip_open_summary:  true
      )
      scan(
        project:  project,
        scheme:   scheme
      )
      sigh
      gym(
        clean: true,
        silent: true,
        project:          project,
        scheme:           scheme,
        output_directory: './build',
        output_name:      'FLSetup'
        )
      deliver(
        force: true,
        screenshots_path: './screenshots',
        ipa: './build'
      )
    end

```

We just need to keep in mind that not everytime we post to AppStore we want to upload all the screenshots and metadata, so we can have alternative workflow for this:

```

    desc "Deploy a new version to the App Store without updating metadata or screenshots"
    lane :deploy do
      sigh
      gym(
        clean: true,
        silent: true,
        scheme: "flsetup",
        output_directory: './build',
        output_name:      'FLSetup'
      )
      deliver(
        force: true,
        skip_metadata: true,
        skip_screenshots: true,
        ipa: './build/FLSetup.ipa'
      )
    end

```

In this repository, Fastfile holds some smaller workflows which enables to test each of the tools invidually. Also, there is complete XCode project which is enough to play with Fastlane configuration.

