# Jitsu iOS SDK Features

[![CI Status](https://img.shields.io/travis/rebbdif/Jitsu.svg?style=flat)](https://travis-ci.org/rebbdif/Jitsu)
[![Version](https://img.shields.io/cocoapods/v/Jitsu.svg?style=flat)](https://cocoapods.org/pods/Jitsu)
[![License](https://img.shields.io/cocoapods/l/Jitsu.svg?style=flat)](https://cocoapods.org/pods/Jitsu)
[![Platform](https://img.shields.io/cocoapods/p/Jitsu.svg?style=flat)](https://cocoapods.org/pods/Jitsu)

 
## Installation
You can install with [Cocoapods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage), or [Swift Package Manager](https://swift.org/package-manager/).

### Cocoapods
Add the pod to your Podfile:
`pod 'jitsu-ios'`

And then run:
`pod install`

After installing the cocoa pod into your project, import Jitsu with
`import Jitsu`

### Carthage
Add Jitsu to your Cartfile:
`github "jitsu/jitsu-ios" "master"`

And then run:
`carthage update --use-xcframeworks` 

Open `Carthage/Build/iOS` directory, and drag jitsu-ios.framework to your application targets “General” tab under the “Linked Frameworks and Libraries” section.

If your app can't find jitsu-ios, go to your target's build settings, and add `$(SRCROOT)`  `recursive`  to your `Framework search path` .

### Swift Package Manager
1. Go to File > Swift Packages > Add Package Dependency
2. Paste the project URL: https://github.com/jitsu/jitsu-ios.git
3. Click on next and select the project target
4. Don't forget to set `DEAD_CODE_STRIPPING = NO` in your `Build Settings` (https://bugs.swift.org/plugins/servlet/mobile#issue/SR-11564)
  **NOTE: For MacOS you must set the `Branch` field to `jitsu/jitsu-ios`
  
  <img src="_Gifs/spm-branch.png" alt="Example" width="600"/>

If you have doubts, please, check the following links:

[How to use](https://developer.apple.com/videos/play/wwdc2019/408/)

[Creating Swift Packages](https://developer.apple.com/videos/play/wwdc2019/410/)

After successfully retrieved the package and added it to your project, just import `Jitsu`, and you can get the full benefits of it.


## Initialisation
SDK is configured with  `JitsuOptions`.
```swift
let options = JitsuOptions(apiKey: YOUR_KEY)
let analytics = JitsuClient(options: options)
```

## Infrastructure
* Jitsu uses an internal queue to make calls fast and non-blocking.
* Jitsu doesn't send all events at once, they are sent in batches. SDK sends a new batch either when the batch reaches `eventsQueueSize`, or every `sendingBatchesPeriod`. Also, events are sent when an application enters background. If the app gets closed or crashes, events are sent on the next launch.
You can manually set the number of events in the queue and time period.
```swift
analytics.eventsQueueSize = 20
analytics.sendingBatchesPeriod = TimeInterval(seconds: 10)
```
Also, you can force SDK to send batch immediately by calling `sendBatch()`.


## Sending events

### Sending events
Telling SDK to track events. There are two options:

a) client can send an event as something conforming to `Event` protocol
```swift
analytics.sendEvent(_ event: Event)
```
b) or pass it as a name of event and Dict of event params.
```swift
analytics.sendEvent(_ name: "user pressed like", params: ["to_user_id: "NEW_VALUE"])
```


### Identifying user
Information about user is passed with events.

Use `analytics.userProperties` to manage user info.
UserProperties consist of an anonymous user id and custom identifiers that you can set to the user.

**anonymous user id**
Jitsu automatically sets a UUID to any user, that is stored between launches. 
You can get it by `analytics.userProperties.anonymousUserId`. 

**user identifier**
You can set your own identifier to user. 
You can access it it by `analytics.userProperties.userIdentifier`. 

**email**
You can set email. 
You can access it it by `analytics.userProperties.email`. 

**other identifiers**
You can set additional user identifiers.
```swift
analytics.userProperties.otherIdentifiers["pager"] = "234" 
```


You can set multiple properties user by calling: 
```swift
analytics.userProperties.identify(
	userIdentifier: "my_id",
	email: "foo@bar.com",
	[
	"name": "Foo",
	"surname": "Johnson",
	],
	sendIdentificationEvent: true
)
```

You can reset all users properties by calling 
``` swift
analytics.userProperties.reset()
```

 
### Passing context with events
Context is added to all the events. It consists of event keys and values. Some values are added to context automatically.
You can add, change and remove context values. It can be helpful in A/B testing, passing user info, or passing user's device characteristics with every event.
`analytics.context.addValues(["age": 32])`
`analytics.context.addValue(32, for: "age"])`

SDK can automatically add context values that are gathered by SDK.

You can remove context values by calling `removeValue(for key: Context.Key)`. You can clear context when needed. It will not clear automatically gathered values (only update them). 
`analytics.context.clear()`

#### Automatically gathered context values
* device info: model, screen size, OS version
* app version, app name, sdk version
* system language
 
 
### Send screen event
You can send an event from a screen in one line. This event will contain screen info as well as event data. 
```swift
analytics.sendScreenEvent(screen: someVC, name: "screen appeared", params: ["foo": "bar"])
```

 
## Out-of-the-box Trackings
1) Main app lifecycle events:
- App installed
- App updated
- App launched
- App did enter background
 
 2) SDK can send events when: 
 * A user receives a push notification, and user opens a push notification. You can turn it off by `analytics.shouldCapturePushEvents = false`
 * App was opened from a deeplink. You can turn it off by `analytics.shouldCaptureDeeplinks = false`
 
 
 ### Location
SDK can gather info about location.
1) You can add location to context by calling 
```swift
analytics.captureLocation(latitude: "12343.43", longitude: "12343.43")
```
2) If user allows app to access location, we gather new location every time app launches. `false` by default.
```swift
analytics.shouldAutomaticallyAddLocationOnAppLaunch = true
```

3) If user allows app to acces  location, we track location changes during the use of the app. `false` by default.
```swift
analytics.shouldTrackLocation = true
```


## Privacy
Disable/enable data collection.

```swift
analytics.turnOff()
```

```swift
analytics.turnOn()
```
 
 
## Logging
You can set log level when initializing SDK with JitsuOptions .
```swift
options.setLogLevel(_ logLevel: JitsuLogLevel)
```
where `JitsuLogLevel` has values `debug`, `info`, `warnings`, `errors`, `critical`
 
 
## UnitTestMode
We need to ensure that events are not being sent during unit tests.
 
