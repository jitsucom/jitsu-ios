//
//  PublicProtocols.swift
//  jitsu-ios
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import Foundation


public typealias EventName = String


// Conform your custom events to this protocol
public protocol Event: AnyObject {
	
	/// Name of the event
	var name: EventName {get}
	
	/// Parameters describing the event
	var params: [String: Any] {get set}
}

/// Used for sending events.
/// You can send events as separate instance, only their names, or their names pluss dict of params.
/// Context is added to all events sent.
public protocol SendsEvents {
	func sendEvent(_ event: Event)

	func sendEvent(name: EventName)
	func sendEvent(name: EventName, params: [String: Any])
	
	var context: Context {get}
	
	/// If SDK shoould track app events:
	/// App installed, App updated, App launched, App did enter background
	var shouldTrackAppEvents: Bool {get set}
}


/// Context is added to all the events. It consists of event keys and values.
/// Some values are added to context automatically.
/// You can add, change and remove context values.
public protocol Context: AnyObject {
	typealias Key = String
	
	/// Use this methods to add or update values in context
	func addValues(_ values: [Context.Key: Any])
	func addValue(_ value: Any, for key: Context.Key)
	
	/// Use this method to remove value for key
	func removeValue(for key: Context.Key)
	
	/// Clears context
	func clear()
	
	/// Default is true. If device info is added to Context: device, screen resolution, OS version.
	/// Is updated on every new launch of the app.
	var shouldCollectDeviceInfo: Bool {get set}
	
	/// Default is true. If we should automatically add user's locale to Context.
	/// Is updated on every new launch of the app.
	var shouldCollectLanguage: Bool {get set}
}


/// Manages user ids
public protocol UserManagement: AnyObject {
	typealias UserId = String
	
	/// We set UUID automatically to any user. UUID is stored between launches.
	var anonymousUserId: UserId {get}
	
	/// Also, clients can set several identifiers to one user and associate these identifiers with one another.
	/// - Parameter newId: new user id to identify with existing ones.
	func identify(newId: UserId)
	
	/// Resetting all user ids.
	func reset()
}


/// Manages SDK behaviour.
public protocol Analytics: AnyObject {
	
	/// Initializing SDK
	/// - Parameters:
	///   - apiKey: Api Key (you can get it in ...) // todo
	///   - hostAdress: adress of Jitsu server
	init?(apiKey: String, hostAdress: String) throws
	
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
	
	// MARK: - Debug
	
	/// You can set different log levels, depending on how detailed you want sdk logs to be
	var logLevel: LogLevel {get set}
}


/// Capturing push events: when push is received, and when push is opened
public protocol CapturesPushEvents: AnyObject {
	/// Should automatically capture this events. Default: true
	var shouldCapturePushEvents: Bool {get set}
}

/// Capturing when application was opened with a deeplink
public protocol CapturesDeeplinks: AnyObject {
	/// Should automatically capture this events. Default: true
	var shouldCaptureDeeplinks: Bool {get set}
}

/// Capturing location
public protocol CapturesLocationEvents: AnyObject {
	/// Default: false
	var shouldAddLocationInfoToContext: Bool {get set}
	
	/// Default: false
	var shouldTrackLocation: Bool {get set}
}


/// Settings different log levels to the SDK.
public enum LogLevel: Int {
	case debug, info, warnings, errors, critical, none
}
