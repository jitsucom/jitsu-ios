//
//  UserPropertiesImpl.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

class JitsuUserPropertiesImpl: JitsuUserProperties {
	
	@Atomic var anonymousUserId: UserId
	
	@Atomic var userIdentifier: UserId?
	
	@Atomic var email: String?
	
	@Atomic var otherIdentifiers = [UserPropertyKey : String]()
	
	typealias JitsuUserPropertiesImplOut = (Event) -> Void
	var out: JitsuUserPropertiesImplOut?
	
	private var storage: UserPropertiesStorage
	
	init(storage: UserPropertiesStorage) {
		self.storage = storage
		
		let userProperties = storage.loadUserProperties()
		if let userProperties = userProperties {
			self.anonymousUserId = userProperties.anonymousUserId
			self.userIdentifier = userProperties.userIdentifier
			self.email = userProperties.email
			self.otherIdentifiers = userProperties.otherIdentifiers
		} else {
			logInfo("no anonymousUserId, creating the new one")
			self.anonymousUserId = UUID().uuidString
			saveUserProperties()
		}
	}
	
	func identify(userIdentifier: UserId?, email: String?, otherIds: [UserPropertyKey : String], sendIdentificationEvent: Bool) {
		logInfo("identifying user with internalId: \(userIdentifier ?? ""), email: \(email ?? ""), otherIds: \(otherIds )")
		self.userIdentifier = userIdentifier
		self.email = email
		self.otherIdentifiers = otherIds
		
		saveUserProperties()
		
		if sendIdentificationEvent {
			out?(IdentifyEvent(payload: self.values()))
		}
	}
	
	func updateUserIdentifier(_ newValue: String?, sendIdentificationEvent: Bool) {
		logInfo("\(#function): \(newValue ?? "")")
		self.userIdentifier = newValue
		
		saveUserProperties()
		
		if sendIdentificationEvent {
			out?(IdentifyEvent(payload: self.values()))
		}
	}
	
	func updateEmail(_ newValue: String?, sendIdentificationEvent: Bool) {
		logInfo("\(#function): \(newValue ?? "")")
		self.email = newValue
		
		saveUserProperties()

		if sendIdentificationEvent {
			out?(IdentifyEvent(payload: self.values()))
		}
	}
	
	func updateOtherIdentifier(_ value: String, forKey: UserPropertyKey, sendIdentificationEvent: Bool) {
		logInfo("\(#function): \(value) forKey: \(forKey)")
		self.otherIdentifiers[forKey] = value
		
		saveUserProperties()

		if sendIdentificationEvent {
			out?(IdentifyEvent(payload: self.values()))
		}
	}
	
	func resetUserProperties() {
		self.anonymousUserId = UUID().uuidString
		self.userIdentifier = nil
		self.email = nil
		self.otherIdentifiers.removeAll()
		
		self.storage.clear()
		saveUserProperties()
	}
		
	func values() -> [String : Any] {
		return [
			"anonymous_id": self.anonymousUserId,
			"internal_id": userIdentifier ?? "no value",
			"email": email ?? "no value",
		].merging(self.otherIdentifiers) {return $1}
	}
	
	private func saveUserProperties() {
		storage.saveUserPropertiesModel(
			UserPropertiesModel(
				anonymousUserId: anonymousUserId,
				userIdentifier: userIdentifier,
				email: email,
				otherIdentifiers: otherIdentifiers)
		)
	}
	
	// MARK: - -
	
	func setup(_ completion: @escaping () -> Void) {
		completion()
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


