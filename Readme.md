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
```Objective-C
JitsuOptions *options = [[JitsuOptions alloc] initWithApiKey:@"YOUR_KEY" trackingHost:@"YOUR_HOST_OR_NIL" logLevel: JitsuLogLevelDebug];
[Jitsu setupClientWith: options];
```

## Sending events

### Sending events
Telling SDK to track events. There are two options:

a) client can send an event as something conforming to `Event` protocol
```swift
analytics.trackEvent(_ event: Event)
```

```Objective-C
//todo
```

b) or pass it as a name of event and Dict of event params.
```swift
analytics.trackEvent(_ name: "user pressed like", params: ["to_user_id: "NEW_VALUE"])
```

```Objective-C
[Jitsu.shared trackEventWithName:@"Hi from Objective-C" payload: @{@"id": [NSUUID new]}];
```


### Identifying user
Information about user is passed with events.

Use `Jitsu.shared.userProperties` or `Jitsu.userProperties` to manage user info.
UserProperties consist of an anonymous user id and custom identifiers that you can set to the user.

* **anonymous user id**: 
Jitsu automatically sets a UUID to any user, that is stored between launches. 
You can get it by `Jitsu.userProperties.anonymousUserId`. 

* **user identifier**: 
You can set your own identifier to user. 
You can access it it by `Jitsu.shared.userProperties.userIdentifier`. 
You can set new identifier with:
```swift
	Jitsu.userProperties.updateUserIdentifier("NEW_ID", sendIdentificationEvent: true)
```
```Objective-C
	[Jitsu.userProperties updateUserIdentifier:@"new identifier" sendIdentificationEvent:NO];
```


* **email**: 
You can set email. 
You can access it it by `Jitsu.shared.userProperties.email`. 
You can update it with:
```swift
	Jitsu.userProperties.updateEmail("new@new.com", sendIdentificationEvent: true)
```
```Objective-C
	[Jitsu.userProperties updateEmail: @"new@new.com" sendIdentificationEvent:TRUE];
```

* **other identifiers**:
You can set additional user identifiers.
You can access it it by `Jitsu.shared.userProperties.otherIdentifiers`. 
You can update it with: 
```swift
	Jitsu.userProperties.updateOtherIdentifier(forKey: "my_key", with: "new_value", sendIdentificationEvent: true)
```
```Objective-C
	[Jitsu.userProperties updateOtherIdentifierForKey:@"my_key" with:@"new_value" sendIdentificationEvent:YES];
```


You can set multiple properties user by calling: 
```swift
Jitsu.userProperties.identify(
	userIdentifier: "my_id",
	email: "foo@bar.com",
	[
		"name": "Foo",
		"surname": "Johnson",
	],
	sendIdentificationEvent: true
)
```

```Objective-C
	[Jitsu.shared.userProperties identifyWithUserIdentifier: @"my_id"
													  email: @"foo@bar.com"
												   otherIds:@{
													   @"name": @"Foo",
													   @"surname": @"Johnson",
												   }
									sendIdentificationEvent: NO];
```

You can reset all users properties. All the properties set before will be reset, and new `anonymous_id` will be generated.
```swift
Jitsu.userProperties.resetUserProperties()
```

```Objective-C
	[Jitsu.userProperties resetUserProperties];
```

### Context
You can set properties that will always be added to events of certain types. 
You can add, change and remove context values.
You can either add properties to certain event types or do not specify event type - then it will be added to all the event types. 
You can also set if you want context values persisted between launches. By default context events are not persisted.

``` swift 
	Jitsu.context.addValues(
		["age": 32, "codes": "Swift"], 
		for: ["event sign up"],
		persist: true
		)
```

```Objective-C
	[Jitsu.context addValues:@{@"language": @"Objective-C"} for: @[@"hi"] persist:NO];
	[Jitsu.context addValues:@{@"general": @"value"} for: nil persist:NO];
```

You can remove context values by calling
```swift
	Jitsu.context.removeValue(for key: "language", for eventTypes: nil)
	Jitsu.context.removeValue(for key: "language", for eventTypes: ["hi"]])
```
```Objective-C
	[Jitsu.shared.context removeValueFor:@"age" for: nil];
	[Jitsu.context removeValueFor:@"language" for: @[@"hi"]];
```

You can clear context when needed. It will not clear automatically gathered values (only update them). 
```swift
	Jitsu.context.clear()
```
```Objective-C
	[Jitsu.context clear];
```

SDK automatically gathers some context values.


#### Automatically gathered context values
* device info: model, screen size, OS version
* app version, app name, sdk version
* system language
* `voice_over: true` if the user has VoiceOver on. 
 
### Send screen event
You can send an event from a screen in one line. This event will contain screen title and screen class as well as event data. 
```swift
		Jitsu.shared.trackScreenEvent(screen: self, event: JitsuBasicEvent(name: "screen opened"))
```

```Objective-C
	[Jitsu.shared trackScreenEventWithScreen:self name:@"screen opened" payload:@{}];
```

 
## Out-of-the-box Trackings
Jitsu can do some tracking for you. 
You can set what to track when initializing SDK with `JitsuOptions`.
*  Main app lifecycle events: `shouldCaptureAppLifecycleEvents`
*  When app was updated or installed
*  User opens a push notification: `shouldCapturePushEvents`
*  App was opened from a deeplink. `shouldCaptureDeeplinks`. We pass the link in payload. *Note: this method will not work if your app uses SceneDelegate. If so, you will have to track opening from deeplink manually in `scene(_ scene: , willConnectTo session: , options connectionOptions: )`*
 
 ### Location
SDK can gather info about location. There are two modes which you can set in options.
SDK uses the permissions that your app has, and would never ask user for permission by itself.
* `trackPermissionChanges` - SDK tracks location permission changes. We add current location permission status to the context, and send events when it changes.
* `addLocationOnAppLaunch` - If user granted access to location, we gather new location every time app launches and add it to the context.
```swift
		options.locationTrackingOptions = [.addLocationOnAppLaunch, .trackPermissionChanges]
```
```Objective-C
	[options setLocationTrackingOptions: @[
		@(LocationTrackingOptionsTrackPermissionChanges),
		@(LocationTrackingOptionsAddLocationOnAppLaunch)
	]];
```

Also there is a special event type method that allows to send location events easily: 
```swift
	let event = LocationEvent(location: location, name: "left bike", payload: [:])
```

```Objective-C
	LocationEvent *event = [[LocationEvent alloc] initWithName: @"hi" location: location payload: @{}];
```


## Privacy
Disable/enable data collection.

```swift
Jitsu.shared.turnOff()
```

```swift
Jitsu.shared.turnOn()
```
We send events `Jitsu turned off` and `Jitsu turned on`
 
 
## Logging
You can set log level when initializing SDK with JitsuOptions .
```swift
options.logLevel = .critical
```
```Objective-C
	[options setLogLevel: JitsuLogLevelInfo];
```
where `JitsuLogLevel` has values `debug`, `info`, `warnings`, `errors`, `critical`, `none`
 
 
## UnitTestMode
1) You can set up your own mock of Jitsu with calling `Jitsu.setupMock:`.  If you pass `nil`, we will create our own empty mock
2) Jitsu automatically tracks if your app is in Unit Testing mode. If so, it disables sending data to the backend and saving it to the database. 
 
 
 ## Advanced Settings
 * Jitsu uses an internal queue to make calls fast and non-blocking.
 * Jitsu doesn't send all events at once, they are sent in batches. SDK sends a new batch either when the batch reaches `eventsQueueSize`, or every `sendingBatchesPeriod`. Also, events are sent when an application enters background. If the app gets closed or crashes, events are sent on the next launch.
 You can manually set the number of events in the queue and time period.
 ```swift
 Jitsu.shared.eventsQueueSize = 20
 Jitsu.shared.sendingBatchesPeriod = TimeInterval(seconds: 10)
 ```
 Also, you can force SDK to send batch immediately by calling `sendBatch()`.
