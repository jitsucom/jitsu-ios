//
//  jitsu_iosTests.swift
//  jitsu-iosTests
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import XCTest
@testable import Jitsu


// MARK: - Draft zone

extension EventType {
	static let showedScreen = "sh"
}


class TestEvent: Event {
	var name: EventType
	
	var payload = [String : Any]()
	
	init(name: EventType) {
		self.name = name
	}
}

class NetworkMock: NetworkService {
	required init(apiKey: String, host: String) {}
	init() {}
	
	func sendBatch(_ batch: EventsBatch, completion: @escaping SendBatchCompletion) {
		sendBatchBlock?(batch)
	}
	
	var sendBatchBlock: ((EventsBatch)-> Void)?
}

class DeviceInfoProviderMock: DeviceInfoProvider {
	var deviceInfo: DeviceInfo?
	
	func getDeviceInfo(_ completion: @escaping (DeviceInfo) -> Void) {
		completion(DeviceInfoProviderMock.mockDeviceInfo)
	}
	
	static let mockDeviceInfo = DeviceInfo(
		manufacturer: "Apple",
		deviceName: "iPhone",
		systemName: "iOS",
		systemVersion: "10",
		screenResolution: "1440x900"
	)
}


class JitsuTests: XCTestCase {
	
	let key1 = "key1"
	let key2 = "key2"
	
	var firstEvent: Event {
		return TestEvent(name: "first event")
	}
	
	var secondEvent: Event {
		return TestEvent(name: "second event")
	}
	
	
	var sdk: JitsuClient!
	var network: NetworkMock!
	
	override func setUp() {
		let options = JitsuOptions(apiKey: "key", trackingHost: "t.jitsu.com/api/v1/event")
		
		network = NetworkMock()
		let deviceInfoProvider = DeviceInfoProviderMock()
		sdk = JitsuClientImpl(
			options: options,
			networkService: network,
			deviceInfoProvider: deviceInfoProvider
		)
	}
	
	func testContext_addValues() throws {
		sdk.eventsQueueSize = 2
		
		let expectation = XCTestExpectation(description: "send batch was called")
		
		let firstParam = [key1: "value1"]
		let secondParam = [key2: "value2"]

		// arrange
		network.sendBatchBlock = { [self] batch in
			XCTAssertEqual(batch.events.count, 2)
			
			let firstEvent = batch.events[0]
			XCTAssertTrue("value1".anyEqual(to: firstEvent.context[key1]))
			XCTAssertNil(firstEvent.context[key2])
			
			let secondEvent = batch.events[1]
			XCTAssertTrue("value1".anyEqual(to: secondEvent.context[key1]))
			XCTAssertTrue("value2".anyEqual(to: secondEvent.context[key2]))
			
			expectation.fulfill()
		}
		
		// act
		sdk.context.addValues(firstParam, for: nil, persist: false)
		sdk.trackEvent(firstEvent)
		
		sdk.context.addValues(secondParam, for: nil, persist: false)
		sdk.trackEvent(secondEvent)

		wait(for: [expectation], timeout: 2)
	}
	
	func testContext_new_values_update_old() throws {
		sdk.eventsQueueSize = 2
		
		let expectation = XCTestExpectation(description: "send batch was called")
		
		// arrange
		network.sendBatchBlock = { [self] batch in
			XCTAssertEqual(batch.events.count, 2)
			
			let firstEvent = batch.events[0]
			XCTAssertTrue("value1".anyEqual(to: firstEvent.context[key1]), "value is \(String(describing: firstEvent.context[key1]))")
			XCTAssertTrue("OLD".anyEqual(to: firstEvent.context[key2]))
			
			let secondEvent = batch.events[1]
			XCTAssertTrue("value1".anyEqual(to: secondEvent.context[key1]))
			XCTAssertTrue("NEW".anyEqual(to: secondEvent.context[key2]))
			expectation.fulfill()
		}
		
		// act
		sdk.context.addValues([key1: "value1"], for: nil, persist: false)
		sdk.context.addValues([key2: "OLD"], for: nil, persist: false)
		sdk.trackEvent(firstEvent)
		
		sdk.context.addValues([key2: "NEW"], for: nil, persist: false)
		sdk.trackEvent(secondEvent)
		
		wait(for: [expectation], timeout: 2)
	}
	
	func testContext_specific_overshadows_general() throws {
		sdk.eventsQueueSize = 2
		
		let expectation = XCTestExpectation(description: "send batch was called")
		
		// arrange
		network.sendBatchBlock = { [self] batch in
			XCTAssertEqual(batch.events.count, 2)
			
			let firstEvent = batch.events[0]
			XCTAssertTrue("OLD".anyEqual(to: firstEvent.context[key1]))
			
			let secondEvent = batch.events[1]
			XCTAssertTrue("NEW".anyEqual(to: secondEvent.context[key1]))
			
			expectation.fulfill()
		}
		
		// act
		
		sdk.context.addValues([key1: "OLD"], for: nil, persist: false)
		sdk.trackEvent(firstEvent)
		
		sdk.context.addValues([key1: "NEW"], for: [firstEvent.name], persist: false)
		sdk.trackEvent(firstEvent)
		
		wait(for: [expectation], timeout: 2)
	}
	
	// general for nil overwrites specific
	func testContext_general_applied_after_specific_replaces_it() throws {
		sdk.eventsQueueSize = 2
		
		let expectation = XCTestExpectation(description: "send batch was called")
		
		// arrange
		network.sendBatchBlock = { [self] batch in
			XCTAssertEqual(batch.events.count, 2)
			
			let firstEvent = batch.events[0]
			XCTAssertTrue("OLD".anyEqual(to: firstEvent.context[key1]))
			
			let secondEvent = batch.events[1]
			XCTAssertTrue("NEW".anyEqual(to: secondEvent.context[key1]))
			
			expectation.fulfill()
		}
		
		// act
		
		sdk.context.addValues([key1: "OLD"], for: [firstEvent.name], persist: false)
		sdk.trackEvent(firstEvent)
		
		sdk.context.addValues([key1: "NEW"], for: nil, persist: false)
		sdk.trackEvent(firstEvent)
		
		wait(for: [expectation], timeout: 2)
	}
	
	func testContext_removeValues() throws {
		sdk.eventsQueueSize = 2
		
		let expectation = XCTestExpectation(description: "send batch was called")
		
		// arrange
		network.sendBatchBlock = { [self] batch in
			XCTAssertEqual(batch.events.count, 2)
			
			let firstEvent = batch.events[0]
			XCTAssertTrue("OLD".anyEqual(to: firstEvent.context[key1]))
			XCTAssertTrue("value_2".anyEqual(to: firstEvent.context[key2]))

			
			let secondEvent = batch.events[1]
			XCTAssertNil(secondEvent.context[key1])
			XCTAssertTrue("value_2".anyEqual(to: firstEvent.context[key2]))
			
			expectation.fulfill()
		}
		
		// act
		
		sdk.context.addValues([key1: "OLD"], for: [firstEvent.name], persist: false)
		sdk.context.addValues([key2: "value_2"], for: nil, persist: false)

		sdk.trackEvent(firstEvent)
		
		sdk.context.removeValue(for: key1, for: nil)
		
		sdk.trackEvent(firstEvent)
		
		wait(for: [expectation], timeout: 2)
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
