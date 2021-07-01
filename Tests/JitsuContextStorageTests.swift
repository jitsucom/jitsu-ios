//
//  JitsuContextStorageTests.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 01.07.2021.
//

import Foundation
@testable import Jitsu


class JitsuContextStorageTests: XCTestCase {
	
	func test_saveSameKeysForDifferentTypes() {
		// arrange
		
		
		// act
		// context.addValues(["custom key": "cool"], for: nil, persist: true)
		// context.addValues(["custom key": "awesome"], for: ["first event"], persist: true)
		
		
		//assert
		// assert that both events are here on load()
	}
	
	func test_updateValue() {
		// arrange
		
		
		// act
		// context.addValues(["custom key": "cool"], for: nil, persist: true)
		// context.addValues(["custom key": "awesome"], for: nil, persist: true)
		
		//assert
		// assert that only `awesome` is here on load()
	}
	
	func test_removeValue() {
		// arrange
		// context.addValues(["custom key": "cool"], for: ["type"], persist: true)
		// context.addValues(["custom key": "awesome"], for: nil, persist: true)
		
		
		// act
		// context.removeValue(forKey: "custom key", eventTYpe: nil)
		
		//assert
		// assert that only `awesome` is here on load()
	}
	
}
