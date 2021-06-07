# Jitsu iOS SDK Features
 
 
## Installation
You can install with [Cocoapods](https://cocoapods.org), [Carthage](https://github.com/Carthage/Carthage), or Swift Package Manager.

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
`carthage update` 

Open `Carthage/Build/iOS` directory, and drag jitsu-ios.framework to your application targets “General” tab under the “Linked Frameworks and Libraries” section.

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
SDK is configured with an `apiKey` and `hostAdress`
```swift
let analytics = Jitsu(apiKey: YOUR_KEY, hostAdress: YOUR_HOST)
```

## Infrastructure
* Jitsu uses an internal queue to make calls fast and non-blocking.
* Jitsu doesn't send all events at once, they are sent by batches. SDK sends a new batch either when the batch reaches `eventsQueueSize`, or every `sendingBatchesPeriod`. Also events are sent when application enters background. If the app gets closed or crashes, events are sent on the next launch.
You can manually set the number of events `n` in the queue and time period `t`.
```swift
analytics.eventsQueueSize = 20
analytics.sendingBatchesPeriod = TimeInterval(seconds: 10)
```
Also you can forse SDK to send batch immediately by calling `sendEvents()`.


## Identifying user
Jitsu automatically sets a UUID to any user, it is stored between launches. You can get it by `analytics.anonymousUserId`. 
You can reset it with `analytics.reset()`.
 
Also, you can set several identifiers to one user and associate these identifiers with one another.
It would be useful in case when you want to identify user before and after login or registration.	
`analytics.identify(newId: NEW_VALUE)`

 
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

### Passing context with events
Context is added to all the events. It consists of event keys and values. Some values are added to context automatically.
You can add, change and remove context values. It can be helpful in A/B testing, passing user info, or passing user's device characteristics with every event.
`analytics.context.addValues(["age": 32])`
`analytics.context.addValue(32, for: "age"])`
 
You can remove context values by calling `removeValue(for key: Context.Key)`, or even clear the context with `clear()`

SDK can automatically add context values that are gathered by SDK (more on that in *Automatically sent values*).

Also, you can clear context when needed. It will not clear automatically gathered values. 
```analytics.context.clear()```
 
 
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
- Sending the screen name on which the app was closed (on the next launch)
You can disable tracking these events if you want to.
```swift
analytics.shouldTrackAppEvents = false
```
 
2) SDK can gather info about:
* device info: model, screen size, OS version. You can disable it with 
`analytics.shouldGatherDeviceInfo = false`
* app version
* System language
* Location. It is turned off, but you can turn it on. with `analytics.shouldAddLocationInfoToContext = true`. // todo: add info about location

3) SDK can send events when: 
* User received push notification, user opened a push notification. You can turn it off by `analytics.shouldCapturePushEvents = false`
* App was opened from a deeplink. You can turn it off by `analytics.shouldCaptureDeeplinks = false`
 
## Privacy
Disable/enable data collection.

```swift
analytics.turnOff()
```

```swift
analytics.turnOn()
```
 
 
## Logging
You can set log level.
```swift
analytics.setLogLevel(_ logLevel: JitsuLogLevel)
```

where `JitsuLogLevel` has values `debug`, `info`, `warnings`, `errors`, `critical`
 
 
# UnitTestMode
We need to ensure that events are not being sent during unit tests.
 
