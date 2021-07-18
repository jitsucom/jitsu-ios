//
//  jitsu_iosTests.swift
//  jitsu-iosTests
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import XCTest
@testable import Jitsu

class JitsuContextTests: XCTestCase {
	
	var networkService: NetworkMock!
	var deviceInfoProvider: DeviceInfoProviderMock!
	var storage: ContextStorage!
	
	override func setUp() {
		networkService = NetworkMock()
		deviceInfoProvider = DeviceInfoProviderMock()
		storage = ContextStorageMock()
	}
	
	func testContext_addValues() throws {
		// arrange
		let context = JitsuContextImpl(storage: storage, deviceInfoProvider: deviceInfoProvider)
		
		// act
		try! context.addValues(["key_1": "value_1"], for: nil, persist: false)
		try! context.addValues(["key_2": "value_2"], for: nil, persist: false)
		
		// assert
		let firstEventValues = context.values(for: "first_event")
		XCTAssertTrue("value_1".jsonValue.anyEqual(to: firstEventValues["key_1"]))
		XCTAssertTrue("value_2".jsonValue.anyEqual(to: firstEventValues["key_2"]))
	}
	
	func testContext_new_values_update_old() throws {
		// arrange
		let context = JitsuContextImpl(storage: storage, deviceInfoProvider: deviceInfoProvider)

		// act
		try! context.addValues(["key_1": "value1"], for: nil, persist: false)
		try! context.addValues(["key_2": "OLD"], for: nil, persist: false)
		
		try! context.addValues(["key_2": "NEW"], for: nil, persist: false)
		
		// assert
		let firstEventValues = context.values(for: "first_event")
		XCTAssertTrue("value1".jsonValue.anyEqual(to: firstEventValues["key_1"]))
		XCTAssertTrue("NEW".jsonValue.anyEqual(to: firstEventValues["key_2"]))
	}
	
	func testContext_new_specific_values_update_old() throws {
		// arrange
		let context = JitsuContextImpl(storage: storage, deviceInfoProvider: deviceInfoProvider)

		// act
		try! context.addValues(["key_1": "value1"], for: ["first_event"], persist: false)
		try! context.addValues(["key_2": "OLD"], for: ["first_event"], persist: false)
		
		try! context.addValues(["key_2": "NEW"], for: ["first_event"], persist: false)
		
		// assert
		let firstEventValues = context.values(for: "first_event")
		XCTAssertTrue("value1".jsonValue.anyEqual(to: firstEventValues["key_1"]))
		XCTAssertTrue("NEW".jsonValue.anyEqual(to: firstEventValues["key_2"]))
	}

	func testContext_specific_overshadows_general() throws {
		// arrange
		let context = JitsuContextImpl(storage: storage, deviceInfoProvider: deviceInfoProvider)

		// act
		try! context.addValues(["key_1": "OLD"], for: nil, persist: false)
		try! context.addValues(["key_1": "NEW"], for: ["first_event"], persist: false)
		
		// assert
		let firstEventValues = context.values(for: "first_event")
		XCTAssertTrue("NEW".jsonValue.anyEqual(to: firstEventValues["key_1"]))
		
		let secondEventValues = context.values(for: "second_event")
		XCTAssertTrue("OLD".jsonValue.anyEqual(to: secondEventValues["key_1"]))
	}
	
	func testContext_specific_isnt_overriten_by_general() throws {
		// arrange
		let context = JitsuContextImpl(storage: storage, deviceInfoProvider: deviceInfoProvider)

		// act
		try! context.addValues(["key_1": "OLD"], for: ["first_event"], persist: false)
		try! context.addValues(["key_1": "NEW"], for: nil, persist: false)
		
		// assert
		let firstEventValues = context.values(for: "first_event")
		XCTAssertTrue("OLD".jsonValue.anyEqual(to: firstEventValues["key_1"]))
	}
	
	func testContext_removeValues_specificStays() throws {
		// arrange
		let context = JitsuContextImpl(storage: storage, deviceInfoProvider: deviceInfoProvider)

		// act
		try! context.addValues(["key_1": "value_1"], for: ["first_event"], persist: false)
		try! context.addValues(["key_2": "value_2"], for: nil, persist: false)
		
		context.removeValue(for: "key_1", for: nil)
		context.removeValue(for: "key_2", for: nil)
		
		// assert
		let firstEventValues = context.values(for: "first_event")
		XCTAssertTrue("value_1".jsonValue.anyEqual(to: firstEventValues["key_1"]))
		XCTAssertNil(firstEventValues["key_2"])
	}
	
	func testContext_removeValues_generalStays() throws {
		// arrange
		let context = JitsuContextImpl(storage: storage, deviceInfoProvider: deviceInfoProvider)

		// act
		try! context.addValues(["key_1": "value_1"], for: ["first_event"], persist: false)
		try! context.addValues(["key_1": "value_2"], for: nil, persist: false)
		
		context.removeValue(for: "key_1", for: ["first_event"])
		
		// assert
		let firstEventValues = context.values(for: "first_event")
		XCTAssertTrue("value_2".jsonValue.anyEqual(to: firstEventValues["key_1"]))

		let anyEventValues = context.values(for: "second_event")
		XCTAssertTrue("value_2".jsonValue.anyEqual(to: anyEventValues["key_1"]))
	}
	
	func test_testContext_safety() throws {
		// arrange
		let context = JitsuContextImpl(storage: storage, deviceInfoProvider: deviceInfoProvider)
	
		// act
		DispatchQueue.global().async {
			try! context.addValues(["key": "1"], for: nil, persist: false)
		}
		DispatchQueue(label: "t1").async {
			try! context.addValues(["key": "2"], for: nil, persist: false)
			try! context.addValues(["key_2": "2"], for: nil, persist: false)
			try! context.addValues(["key_3": "2"], for: nil, persist: false)
			context.clear()
			try! context.addValues(["key_4": "4"], for: nil, persist: false)
		}
		
		try! context.addValues(["key": "3"], for: nil, persist: false)

		DispatchQueue(label: "t2").async {
			try! context.addValues(["key": "4"], for: nil, persist: false)
		}
		
		let _ = context.values(for: nil)
		
		//assert
		//no-throw
	}
}


extension Equatable {
	func anyEqual(to value: Any?) -> Bool {
		guard let value = value as? Self else {
			return false
		}
		
		return value == self
	}
}
