//
//  PublicProtocols.swift
//  jitsu-ios
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import Foundation


public typealias EventName = String


// Conform your custom events to this protocol
@objc public protocol Event: AnyObject {
	
	/// Name of the event
	var name: EventName {get}
	
	/// Parameters describing the event
	var payload: [String: Any] {get set}
}

/// Used for sending events.
/// You can send events as separate instance, only their names, or their names pluss dict of payload.
/// Context is added to all events sent.
@objc public protocol SendsEvents {

	func trackEvent(_ event: Event)

	func trackEvent(name: EventName)
	func trackEvent(name: EventName, payload: [String: Any])
	
	var context: EventContext {get}
}

/// Context is added to all the events. It consists of event keys and values.
/// Some values are added to context automatically.
/// You can add, change and remove context values.
@objc public protocol EventContext: AnyObject {
	typealias Key = String
	
	/// Use this methods to add or update values in context
	func addValues(_ values: [EventContext.Key: Any])
	func addValue(_ value: Any, for key: EventContext.Key)
	
	/// Use this method to remove value for key
	func removeValue(for key: EventContext.Key)
	
	/// Clears context
	func clear()
	
	/// If device info is added to Context: device, screen resolution, OS version, app version
	/// Is updated on every new launch of the app.
	/// Default is true.
	var shouldCollectDeviceInfo: Bool {get set}
	
	/// If we should automatically add user's locale to Context.
	/// Is updated on every new launch of the app.
	/// Default is true.
	var shouldCollectLanguage: Bool {get set}
}

@objc public protocol UserProperties: AnyObject {
	typealias UserId = String
	typealias UserIdKey = String
	
	var anonymousUserId: UserId {get set}
	var userIdentifier: UserId? {get set}
	var email: String? {get set}
	var otherIdentifiers: [UserIdKey: String] {get}
	func setOtherIdentifiers(_ identifiers: [UserIdKey: String])
}

/// Configuration options for Jitsu.
@objc public class JitsuOptions: NSObject {
	
	/// You can set different log levels, depending on how detailed you want sdk logs to be
	var logLevel: LogLevel = .warnings
	
	/// Should automatically capture this events. Default: true
	var shouldCaptureDeeplinks: Bool = true
	
	/// Should automatically capture this events. Default: true
	var shouldCapturePushEvents: Bool = true
	
}

/// Manages SDK behaviour.
@objc public protocol JitsuClient: AnyObject {
	
	/// Initializing SDK
	/// - Parameters:
	///   - apiKey: Api Key
	///	  - options: Jitsu options
	init(apiKey: String, options: JitsuOptions)
	
	// MARK: - User Properties
	
	/// <#Description#>
	var userProperties: UserProperties {get}
	
	/// <#Description#>
	/// - Parameters:
	///   - userProperties: <#userProperties description#>
	///   - sendEvent: <#sendEvent description#>
	func identify(with userProperties: UserProperties, sendEvent: Bool)
	
	/// Resetting all user ids.
	func resetUserProperties()
	
	// MARK: - Managing SDK
	
	/// If user wants to disable all the analytics, call `turnOff` method.
	/// If user wants to turn it on back - call `turnOn`.
	/// By default analytics is turned on.
	func turnOff()
	func turnOn()
	
	// MARK: - Sending events to backend
	
	/// SDK doesn't send all events at once, they are sent by batches.
	/// SDK sends a new batch either when the batch reaches`eventsQueueSize`, or every `sendingBatchesPeriod`.
	/// Also events are sent when application enters background.
	/// If application crashes, events are sent on the next launch.

	var eventsQueueSize: Int {get set}
	var sendingBatchesPeriod: TimeInterval {get set}
	
	/// You can send current batch manually.
	func sendEvents()
}


/// Capturing location
@objc public protocol CapturesLocationEvents: AnyObject {

	/// Captures user's location, so it gets added to all the future events
	func captureLocation(latitude: String, longitude: String)
	
	/// If user granted access to location, we gather new location every time app launches
	/// Default: false
	var shouldAutomaticallyAddLocationOnAppLaunch: Bool {get set}
	
	/// If user granted access to location, we track location changes during the use of the app
	/// Default: false
	var shouldTrackLocation: Bool {get set}
}


/// Settings different log levels to the SDK.
@objc public enum LogLevel: Int {
	case debug, info, warnings, errors, critical, none
}
