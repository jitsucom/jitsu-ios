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
	
	init() {
		self.anonymousUserId = UUID().uuidString
	}
	
	func identify(userIdentifier: UserId?, email: String?, _ otherIds: [UserPropertyKey : String], sendIdentificationEvent: Bool) {
		
	}
	
	func resetUserProperties() {
		
	}
	
	// MARK: - -
	
	func values() -> [String : Any] {
		return [:]
	}
	
}
