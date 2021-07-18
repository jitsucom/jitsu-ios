//
//  JitsuClientMock.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 18.07.2021.
//

import Foundation
import UIKit

class JitsuClientMock: JitsuClient {
	
	func trackEvent(_ event: Event) {}
	
	func trackEvent(name: EventType) {}
	
	func trackEvent(name: EventType, payload: [String : Any]) {}
	
	var context: JitsuContext = JitsuContextMock()
	
	var userProperties: UserProperties = UserPropertiesMock()
	
	var eventsQueueSize: Int = 5
	
	var sendingBatchesPeriod: TimeInterval = 20
	
	func sendBatch() {}
	
	func turnOff() {}
	
	func turnOn() {}
	
	func trackScreenEvent(screen: UIViewController, name: EventType, payload: [String : Any]) {}
	
	func trackScreenEvent(screen: UIViewController, event: Event) {}
}

class JitsuContextMock: JitsuContext {
	func addValues(_ values: [String : Any], for eventTypes: [EventType]?, persist: Bool) throws {}
	
	func removeValue(for key: String, for eventTypes: [EventType]?) {}
	
	func clear() {}
	
	func values(for eventType: EventType?) -> [String : Any] {
		return [:]
	}
}

class UserPropertiesMock: UserProperties {
	var anonymousUserId: UserId = "None"
	
	var userIdentifier: UserId?
	
	func updateUserIdentifier(_ newValue: String?, sendIdentificationEvent: Bool) {}
	
	var email: String?
	
	func updateEmail(_ newValue: String?, sendIdentificationEvent: Bool) {}
	
	var otherIdentifiers = [UserPropertyKey : String]()
	
	func updateOtherIdentifier(_ value: String, forKey: UserPropertyKey, sendIdentificationEvent: Bool) {}
	
	func identify(userIdentifier: UserId?, email: String?, otherIds: [UserPropertyKey : String], sendIdentificationEvent: Bool) {}
	
	func resetUserProperties() {}
	
	func values() -> [String : Any] {
		return [:]
	}
}
