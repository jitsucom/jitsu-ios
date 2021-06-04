//
//  PublicProtocols.swift
//  jitsu-ios
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import Foundation


// MARK: - Sending Events

public typealias EventName = String

public protocol Event: AnyObject {
	var name: EventName {get}
	var params: [String: Any] {get set}
}


public protocol SendsEvents {
	
	func sendEvent(_ event: EventName)
	
	func sendEvent(name: EventName)
	func sendEvent(name: EventName, params: [String: Any])
	
	func sendScreen()

	var context: Context {get}
}


public protocol Context: AnyObject {
	typealias Key = String
	
	func addValues(_ values: [Context.Key: Any])
	func addValue(_ value: Any, for key: Context.Key)
	
	func removeValue(for key: Context.Key)
	
	/// Clears values that were set by user.
	func clear()
	
}

public protocol UserManagement: AnyObject {
	typealias UserId = String
	
	var userId: UserId {get}
	func identify(newId: UserId)
	
	func reset()
}


public protocol Analytics: AnyObject {
	
	init?(apiKey: String, hostAdress: String) throws
	
	func turnOff()
	func turnOn()
	
	var eventsQueueSize: Int {get set}
	var sendingBatchesPeriod: TimeInterval {get set}
	
	var shouldCollectDeviceInfo: Bool {get set}
	var shouldCollectLanguage: Bool {get set}
	
	var logLevel: LogLevel {get set}
}


public enum LogLevel: Int {
	case debug, info, warnings, errors, critical, none
}


// MARK: - Draft zone

extension EventName {
	static let showedScreen = "sh"
}

