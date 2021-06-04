Jitsu iOS SDK Features
 
 
# Installation
Cocoapods or Carthage or Swift Package Manager

### Cocoapods
Add the pod to your Podfile:
`pod 'jitsu-ios'`

And then run:
`pod install`

After installing the cocoapod into your project import Jistu with
`import Jitsu`

More on Cocoapods: https://cocoapods.org

### Carthage
Add Jitsu to your Cartfile:
`github "jitsu/jitsu-ios" "master"`

And then run:
`carthage update` 

In your application targets “General” tab under the “Linked Frameworks and Libraries” section, drag and drop jitsu-ios.framework from the Carthage/Build/iOS directory that carthage update produced.

More on Carthage: https://github.com/Carthage/Carthage


### Swift Package Manager
``` swift
// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "YourTestProject",
  platforms: [
       .iOS(.v12),
  ],
  dependencies: [
    .package(url: "https://github.com/jitsu/jitsu-ios.git")
  ],
  targets: [
    .target(name: "YourTestProject", dependencies: ["Jitsu"])
  ]
)
```
And then import wherever needed: ```import Jitsu```

#### Adding it to an existent iOS Project via Swift Package Manager

1. Using Xcode 11 go to File > Swift Packages > Add Package Dependency
2. Paste the project URL: https://github.com/jitsu/jitsu-ios.git
3. Click on next and select the project target
4. Don't forget to set `DEAD_CODE_STRIPPING = NO` in your `Build Settings` (https://bugs.swift.org/plugins/servlet/mobile#issue/SR-11564)
  **NOTE: For MacOS you must set the `Branch` field to `jitsu/jitsu-ios`
  
  <img src="_Gifs/spm-branch.png" alt="Example" width="600"/>

If you have doubts, please, check the following links:

[How to use](https://developer.apple.com/videos/play/wwdc2019/408/)

[Creating Swift Packages](https://developer.apple.com/videos/play/wwdc2019/410/)

After successfully retrieved the package and added it to your project, just import `Jitsu` and you can get the full benefits of it.


# Initialisation
SDK is configured with an `apiKey` and `hostAdress`
 
 
# Infrastructure
1) Uses an internal queue to make calls fast and non-blocking
2) Batches requests and flushes asynchronously:
* Waits until `n` events queue. Then these events are sent in a single batch.
* And it can send events every `t` seconds
* When the app is closed, SDK persists events that were not sent, and sends them on the next app launch (not immediately at launch, but with a little delay, in order not to slow down app launch processes).
 
Clients can manually set the number of events `n` in the queue and time period `t`.
 
 
# Identifying user
We set UUID automatically to any user. UUID is stored between launches.
Clients can get it by `analytics.getUserId()`.
Clients can reset this UUID when they need to.
`analytics.resetUserId()`.
 
Also, clients can set several identifiers to one user and associate these identifiers with one another.
It would be useful in case when client wants to identify user before and after login or registration.
`analytics.identify(id1, id2)`
 
 
# Sending events

### Sending events
Telling SDK to track events. There are two options:
a) client can send an event as something conforming to JitsuEvent protocol
`sendEvent(_ event: JitsuEvent)`
b) or pass it as a name of event and Dict of event params.
`sendEvent(_ name: Strings, params: Dict)`
 
### Passing context with events
Clients can set the context to the SDK that will be passed with the events.
It can be helpful in A/B testing, passing user info, or passing user's device characteristics with every event.
 
Client can set context to sdk, then context is added to all events.
`analytics.setContext(_ context: JitsuContext)`
`analytics.setContext(_ context: Dict)`
 
Client can add or change or remove context values
`analytics.context.setValue(for key: String)`
`analytics.context.removeValue(for key: String)`
 
SDK can automatically add context values that are gathered by SDK (more on that in *Automatically sent values*).
 
### Send screen event
Client can send event from screen in one line
 
 
# Out-of-the-box Tracking
1) Main app lifecycle events:
- App installed
- App updated
- App did enter background
- Sending the screen name on which the app was closed (on the next launch)
Client can decide which events they need.
For instance:
`analytics.shouldTrackAppInstalled = true`
`analytics.shouldTrackAppUpdated = false`.
 
2) SDK can gather info about:
* device info: model, screen size, OS version
`analytics.shouldGatherDeviceInfo = true`
* System language
 
 
# Privacy
Disable/enable data collection.

`analytics.turnOff()`

`analytics.turnOn()`
 
 
# Logging
You can set log level.
`analytics.setLogLevel(_ logLevel: JitsuLogLevel)`,

where `JitsuLogLevel` has values `debug`, `info`, `warnings`, `errors`, `critical`
 
 
# UnitTestMode
We need to ensure that events are not being sent during unit tests.
 
