# Jitsu iOS SDK Features

[Jitsu: Open Source Real-time Data Collection](https://jitsu.com)

[![CocoaPods](https://img.shields.io/cocoapods/v/Jitsu.svg?style=flat-square)](https://cocoapods.org/pods/Jitsu)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-orange.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange.svg?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)

[![License](https://img.shields.io/cocoapods/l/Jitsu.svg?style=flat)](https://cocoapods.org/pods/Jitsu)

 
## Installation
You can install with [Cocoapods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage), or [Swift Package Manager](https://swift.org/package-manager/).

### Cocoapods
Add the pod to your Podfile:
`pod 'Jitsu'`

And then run:
`pod install`

After installing the cocoa pod into your project, import Jitsu into your project. 

### Carthage
Add Jitsu to your Cartfile:
`github "jitsu/jitsu-ios" "develop"`

And then run:
`carthage update --use-xcframeworks` 

Open `Carthage/Build` directory, and drag Jitsu.framework to your application targets “General” tab under the “Linked Frameworks and Libraries” section.

If your app can't find Jitsu, go to your target's build settings, and add `$(SRCROOT)`  `recursive`  to your `Framework search path` .

Then import Jitsu into your project.


### Swift Package Manager
1. Go to File > Swift Packages > Add Package Dependency
2. Paste the project URL: https://github.com/jitsu/jitsu-ios.git
3. Click on next and select the project target
4. Don't forget to set `DEAD_CODE_STRIPPING = NO` in your `Build Settings` (https://bugs.swift.org/plugins/servlet/mobile#issue/SR-11564)
  **NOTE: For MacOS you must set the `Branch` field to `jitsu/jitsu-ios`
  
  <img src="_Gifs/spm-branch.png" alt="Example" width="600"/>

After successfully retrieved the package and added it to your project, import Jitsu.

### Importing Jitsu

Swift: 
```swift 
import Jitsu
```

Objective-C: 
```Objective-C
@import Jitsu;
```

## Initialisation
SDK is configured with  `JitsuOptions`.
You should pass your API key to it, and a tracking host, if you want to use custom host. 

Swift: 
```swift
let options = JitsuOptions(apiKey: YOUR_KEY, trackingHost: YOUR_HOST)
let analytics = JitsuClient(options: options)
```

Objective-C: 
```objc
JitsuOptions *options = [[JitsuOptions alloc] initWithApiKey:@"KEY" trackingHost:@"Host" logLevel: JitsuLogLevelDebug];
[Jitsu setupClientWith: options];
```

## Sending events

### Sending events
Telling SDK to track events. There are two options:

a) client can send an event as something conforming to `Event` protocol
```swift
analytics.trackEvent(_ event: Event)
```
b) or pass it as a name of event and Dict of event params.
```swift
analytics.trackEvent(_ name: "user pressed like", params: ["to_user_id: "NEW_VALUE"])
```


### Identifying user
Information about user is passed with events.

Use `analytics.userProperties` to manage user info.
UserProperties consist of an anonymous user id and custom identifiers that you can set to the user.

* **anonymous user id**: 
Jitsu automatically sets a UUID to any user, that is stored between launches. 
You can get it by `analytics.userProperties.anonymousUserId`. 

* **user identifier**: 
You can set your own identifier to user. 
You can access it it by `analytics.userProperties.userIdentifier`. 

* **email**: 
You can set email. 
You can access it it by `analytics.userProperties.email`. 

* **other identifiers**:
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

### Context
You can set properties that will always be added to events of certain types. 
You can add, change and remove context values.
You can either add properties to certain event types or do not specify event type - then it will be added to all the event types. 

You can also set if you want context values persisted between launches. By default context events are persisted.

``` swift 
Jitsu.shared.context.addValues(
	["age": 32, "codes": "Swift"], 
	for: ["event sign up"],
	persist: true
	)
```

```objc
NSError *error = nil;
[Jitsu.shared.context addValues:@{@"language": @"Objective-C"} for: @[@"hi"] persist:NO error: &error];
```

You can remove context values by calling
```swift
analytics.context.removeValue(for key: "age", for eventTypes: [])
```

You can clear context when needed. It will not clear automatically gathered values (only update them). 
`analytics.context.clear()`

SDK automatically gathers some context values.


#### Automatically gathered context values
* device info: model, screen size, OS version
* app version, app name, sdk version
* system language
 
 
### Send screen event
You can send an event from a screen in one line. This event will contain screen title and screen class as well as event data. 
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
 * User opens a push notification. You can turn it off by `analytics.shouldCapturePushEvents = false`
 * App was opened from a deeplink. You can turn it off by `analytics.shouldCaptureDeeplinks = false`. We pass the link in payload.
	*Note: this method will not work if your app uses SceneDelegate. If so, you will have to track opening from deeplink manually in `scene(_ scene: , willConnectTo session: , options connectionOptions: )`*
 3) We add context value `voice_over: true` if the user has VoiceOver on. 
 
 ### Location
SDK can gather info about location.
1) You can add location to context by calling 
```swift
analytics.captureLocation(latitude: -33.85663289818548, longitude: 151.2153074248861)
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
We send events `Jitsu turned off` and `Jitsu turned on`
 
 
## Logging
You can set log level when initializing SDK with JitsuOptions .
```swift
options.setLogLevel(_ logLevel: JitsuLogLevel)
```
where `JitsuLogLevel` has values `debug`, `info`, `warnings`, `errors`, `critical`
 
 
## UnitTestMode
1) You can set up your own mock of Jitsu with calling `Jitsu.setupMock:`.  If you pass `nil`, we will create our own empty mock
2) Jitsu automatically tracks if your app is in Unit Testing mode. If so, it disables sending data to the backend and saving it to the database. 
 
 
 ## Advanced Settings
 * Jitsu uses an internal queue to make calls fast and non-blocking.
 * Jitsu doesn't send all events at once, they are sent in batches. SDK sends a new batch either when the batch reaches `eventsQueueSize`, or every `sendingBatchesPeriod`. Also, events are sent when an application enters background. If the app gets closed or crashes, events are sent on the next launch.
 You can manually set the number of events in the queue and time period.
 ```swift
 analytics.eventsQueueSize = 20
 analytics.sendingBatchesPeriod = TimeInterval(seconds: 10)
 ```
 Also, you can force SDK to send batch immediately by calling `sendBatch()`.
