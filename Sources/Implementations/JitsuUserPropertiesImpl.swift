//
//  UserPropertiesImpl.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation


class JitsuUserPropertiesImpl: UserProperties {
	
	var anonymousUserId: UserId
	
	var userIdentifier: UserId?
	
	var email: String?
	
	var otherIdentifiers = [UserPropertyKey : String]()
	
	typealias JitsuUserPropertiesImplOut = (Event) -> Void
	var out: JitsuUserPropertiesImplOut?
	
	init() {
		self.anonymousUserId = UUID().uuidString
	}
	
	func identify(userIdentifier: UserId?, email: String?, _ otherIds: [UserPropertyKey : String], sendIdentificationEvent: Bool) {
		self.userIdentifier = userIdentifier
		self.email = email
		self.otherIdentifiers = otherIds
		
		if sendIdentificationEvent {
			out?(IdentifyEvent(payload: self.values()))
		}
	}
	
	func updateUserIdentifier(_ newValue: String?, sendIdentificationEvent: Bool) {
		self.userIdentifier = newValue
		if sendIdentificationEvent {
			out?(IdentifyEvent(payload: self.values()))
		}
	}
	
	func updateEmail(_ newValue: String?, sendIdentificationEvent: Bool) {
		self.email = newValue
		if sendIdentificationEvent {
			out?(IdentifyEvent(payload: self.values()))
		}
	}
	
	func updateOtherIdentifier(_ value: String, forKey: UserPropertyKey, sendIdentificationEvent: Bool) {
		self.otherIdentifiers[forKey] = value
		if sendIdentificationEvent {
			out?(IdentifyEvent(payload: self.values()))
		}
	}
	
	func resetUserProperties() {
		self.anonymousUserId = UUID().uuidString
		self.userIdentifier = nil
		self.email = nil
		self.otherIdentifiers.removeAll()
	}
	
	// MARK: - -
	
	func values() -> [String : Any] {
		return [
			"anonymous_id": self.anonymousUserId,
			"internal_id": userIdentifier ?? "no value",
			"email": email ?? "no value",
		].merging(self.otherIdentifiers) {return $1}
	}
	
	
	class IdentifyEvent: Event {
		var name: EventType
		var payload: [String : Any]
		
		init(
			payload: [String : Any]
		) {
			self.name = "jitsu event: user identified"
			self.payload = payload
		}
	}
}


