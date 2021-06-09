//
//  PublicProtocols.swift
//  jitsu-ios
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import Foundation


public typealias EventName = String


/// Manages SDK behaviour.
@objc public protocol JitsuClient: AnyObject {
	
	/// Initializing SDK
	init(options: JitsuOptions)
	
	// MARK: - Tracks events
	
	/// You can send events as separate instance, only their names, or their names plus dict of payload.
	/// Context is added to all events sent.
	func trackEvent(_ event: Event)
	func trackEvent(name: EventName)
	func trackEvent(name: EventName, payload: [String: Any])
	
	var context: EventContext {get}
	
	/// User properties are added to events that SDK sends.
	var userProperties: UserProperties {get}
	
	// MARK: - Sending events infrastructure
	
	/// SDK doesn't send all events at once, they are sent by batches.
	/// SDK sends a new batch either when the batch reaches`eventsQueueSize`, or every `sendingBatchesPeriod`.
	/// Also events are sent when application enters background.
	/// If application crashes, events are sent on the next launch.
	
	var eventsQueueSize: Int {get set}
	var sendingBatchesPeriod: TimeInterval {get set}
	
	/// You can send current batch manually.
	func sendBatch()
	
	// MARK: - Managing SDK
	
	/// If user wants to disable all the analytics, call `turnOff` method.
	/// If user wants to turn it on back - call `turnOn`.
	/// By default analytics is turned on.
	func turnOff()
	func turnOn()
}

/// Conform your custom events to this protocol
@objc public protocol Event: AnyObject {
	
	/// Name of the event
	var name: EventName {get}
	
	/// Parameters describing the event
	var payload: [String: Any] {get set}
}

/// Context is added to all the events. It consists of event keys and values.
/// Some values are added to context automatically.
/// You can add, change and remove context values.
@objc public protocol EventContext: AnyObject {
	typealias Key = String
	
	/// Use this methods to add or update values in context.
	func addValues(_ values: [EventContext.Key: Any])
	func addValue(_ value: Any, for key: EventContext.Key)
	
	/// Use this method to remove value for key.
	func removeValue(for key: EventContext.Key)
	
	/// Clears context. Automatically collected values are reset and then added again.
	func clear()
}

/// Manages user properties.
@objc public protocol UserProperties: AnyObject {
	typealias UserId = String
	typealias UserPropertyKey = String
	
	/// User id that is set inside the sdk. It is persisted between launches.
	var anonymousUserId: UserId {get}
	
	/// You can set your own user id. If not set, first known id from `otherIdentifiers` will be taken.
	var userIdentifier: UserId? {get set}
	
	/// User's email
	var email: String? {get set}
	
	/// You can set additional user identifiers.
	var otherIdentifiers: [UserPropertyKey: String] {get set}
	
	/// Identifies user with data.
	/// anonymousUserId stays  same.
	/// - Parameters:
	///   - userIdentifier: user's identifier.
	///   - email: users email.
	///   - otherIds: other identifiers. New values replace the old ones.
	///   - sendIdentificationEvent:if separate identification event should be sent to the server. `true` by default.
	func identify(
		userIdentifier: UserId?,
		email: String?,
		_ otherIds: [UserPropertyKey: String],
		sendIdentificationEvent: Bool
	)
	
	/// Resetting all user ids. New `anonymousUserId` will be generated.
	func resetUserProperties()
}


/// Configuration options for Jitsu.
@objc public class JitsuOptions: NSObject {
	
	/// API Key
	var apiKey: String
	
	/// Should automatically capture this events. Default: true
	var shouldCaptureDeeplinks: Bool = true

	/// Should automatically capture this events. Default: true
	var shouldCapturePushEvents: Bool = true
	
	/// You can set different log levels, depending on how detailed you want sdk logs to be
	var logLevel: LogLevel = .warnings
	
	@objc public init(apiKey: String) {
		self.apiKey = apiKey
		super.init()
	}
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
