//
//  PublicProtocols.swift
//  jitsu-ios
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import Foundation

public typealias EventType = String

/// You can pass any value that is JSON-convertable.
/// It can be Swift types or their Objective-C toll-free-bridged types.
/// nil, Bool, Decimal numbers (Int, Double, Float, etc), String, Array<AnyJSONValue>, dict<AnyJSONValue>.
/// Also it can handle UUIDs and URLs.
/// If you pass not appropriate value, SDK will throw an exception
public typealias AnyJSONValue = Any


/// Manages SDK behaviour.
@objc public protocol JitsuClient: AnyObject, TracksUIKitEvents {
	
	// MARK: - Tracks events
	
	/// You can send events as separate instance, only their names, or their names plus dict of payload.
	/// Context is added to all events sent.
	func trackEvent(_ event: Event)
	func trackEvent(name: EventType)
	func trackEvent(name: EventType, payload: [String: AnyJSONValue])
	
	/// Context is added to all the events. It consists of event keys and values. Some values are added to context automatically.
	var context: JitsuContext {get}
	
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
	var name: EventType {get}
	
	/// Parameters describing the event
	var payload: [String: AnyJSONValue] {get set}
}

/// Context is added to all the events. It consists of event keys and values.
/// Some values are added to context automatically.
/// You can add, change and remove context values.
@objc public protocol JitsuContext: AnyObject {
	typealias Key = String
	
	/// Sets permanent properties for certain event types, that can be saved between launches.
	/// - Parameters:
	///   - values: properties
	///   - eventTypes: apply permanent properties to only certain event types (applied to all types if `nil`).
	///   - persist: if true, properties are saved between launches. true by default
	func addValues(_ values: [JitsuContext.Key: AnyJSONValue], for eventTypes: [EventType]?, persist: Bool)
	
	/// Use this method to remove value for key for certain event types.
	/// - Parameters:
	///   - key: key of property to be removed
	///   - eventTypes: types of events for which you want to remove the property. Removed from all types if `nil`.
	func removeValue(for key: JitsuContext.Key, for eventTypes: [EventType]?)
	
	/// Clears context. Automatically collected values are reset and then added again.
	func clear()
	
	/// Get values for certain event type (plus values that don't have specified event type).
	/// If `nil` - you will get all generic values.
	/// Value applied to specific type overshadows general value
	/// (e.g. if general context has "foo": "1", and private has "foo": "2", you will get "foo": "2").
	func values(for eventType: EventType?) -> [String : AnyJSONValue]
	
}

extension JitsuContext {
	public func addCodableValues<T: Codable>(_ values: [JitsuContext.Key : T], for eventTypes: [EventType]?, persist: Bool) {
		let jsonValues = try! values.mapValues { (value) -> JSON in
			return try JSON(withCodable: value)
		}
		
		addValues(jsonValues, for: eventTypes, persist: persist)
	}
}

/// Manages user properties.
@objc public protocol UserProperties: AnyObject {
	typealias UserId = String
	typealias UserPropertyKey = String
	
	/// User id that is set inside the sdk. It is persisted between launches.
	var anonymousUserId: UserId {get}
	
	/// You can set your own user id. If not set, first known id from `otherIdentifiers` will be taken.
	var userIdentifier: UserId? {get}
	func updateUserIdentifier(_ newValue: String?, sendIdentificationEvent: Bool)

	/// User's email
	var email: String? {get}
	func updateEmail(_ newValue: String?, sendIdentificationEvent: Bool)
	
	/// You can set additional user identifiers.
	var otherIdentifiers: [UserPropertyKey: String] {get}
	func updateOtherIdentifier(_ value: String, forKey: UserPropertyKey, sendIdentificationEvent: Bool)

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
		otherIds: [UserPropertyKey: String],
		sendIdentificationEvent: Bool
	)
	
	/// Resetting all user ids. New `anonymousUserId` will be generated.
	func resetUserProperties()
	
	func values() -> [String : AnyJSONValue]
}

/// Configuration options for Jitsu.
@objc public class JitsuOptions: NSObject {
	
	/// API Key
	var apiKey: String
	
	/// Tracking host (where API calls will be sent). If not set,
	/// we'd try to do the best to "guess" it. Last resort is t.jitsu.com.
	var trackingHost: String
	private static let defaultTrackingHost: String = "https://t.jitsu.com/api/v1/event"
	
	// MARK: - Out-of-the-box tracking
	
	/// Should automatically capture this events. Default: true
	@objc public var shouldCaptureDeeplinks: Bool = true

	/// Should automatically capture this events. Default: true
	@objc public var shouldCapturePushEvents: Bool = true
	
	// MARK: - Location
	
	@objc public enum LocationTrackingOptions: Int {
		
		/// If user granted access to location, we gather new location every time app launches
		case addLocationOnAppLaunch
		
		/// If user granted access to location, we track results of locations requests that your app sends
		case trackLocation
		
		/// We add current location permission status to the context, and send events when it changes.
		case trackPermissionChanges
	}
	
	/// You can set location tracking options that you want, so Jitsu will help you with tracking the location information.
	public var locationTrackingOptions = [LocationTrackingOptions]()
	/// Same property as `locationTrackingOptions`, but you have to pass LocationTrackingOptions raw values.
	@objc public func setLocationTrackingOptions(_ rawValues: [Int]) {
		locationTrackingOptions = rawValues.compactMap { LocationTrackingOptions(rawValue: $0)}
	}
	
	// MARK: - Development
	
	/// You can set different log levels, depending on how detailed you want sdk logs to be
	@objc public var logLevel: JitsuLogLevel = .warning
	
	///`true` if it is in UnitTests.
	/// If `true`, SDK will be mocked.
	@objc public var inTestMode: Bool {
		if let _ = NSClassFromString("XCTestCase") {
			return true
		} else {
			return false
		}
	}
	
	@objc public init(apiKey: String, trackingHost: String?, logLevel: JitsuLogLevel = .warning) {
		self.apiKey = apiKey
		self.trackingHost = trackingHost ?? JitsuOptions.defaultTrackingHost
		self.logLevel = logLevel
		super.init()
	}
}

/// Settings different log levels to the SDK.
@objc public enum JitsuLogLevel: Int {
	case debug = 0
	case info
	case warning
	case error
	case critical
	case none
}
