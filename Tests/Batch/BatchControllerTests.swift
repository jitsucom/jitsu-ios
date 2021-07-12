//
//  BatchControllerTests.swift
//  JitsuTests
//
//  Created by Leonid Serebryanyy on 07.07.2021.
//

import XCTest
@testable import Jitsu

class BatchControllerTests: XCTestCase {
	
	func test_buildBatch() {
		// arrange
		let firstEvent = EnrichedEvent(
			eventId: "1", name: "first", utcTime: "now", localTimezoneOffset: 3,
			payload: ["firstPayload": "boo".jsonValue],
			context: ["app_build_id": "1.1".jsonValue, "some": 3.jsonValue],
			userProperties: ["email": "test@test.test".jsonValue,
							 "other": ["boo": "bar", "foo": "far"].jsonValue
			]
		)

		let secondEvent = EnrichedEvent(
			eventId: "2", name: "second", utcTime: "now + 1", localTimezoneOffset: 3,
			payload: ["secondPayload": "boo".jsonValue],
			context: ["app_build_id": "1.1".jsonValue, "some": 3.jsonValue],
			userProperties: ["email": "test@test.test".jsonValue]
		)

		// act
		let batch = BatchesController.buildBatch(unbatchedEvents: [firstEvent, secondEvent])

		// assert
		let expectedTemplate = [
			"app_build_id": "1.1".jsonValue,
			"some": 3.jsonValue,
			"email": "test@test.test".jsonValue,
			"local_tz_offset": 3.jsonValue,
		]
		XCTAssertEqual(expectedTemplate, batch.template)
		
		let expectedFirstEvent = [
			"event_id": "1".jsonValue, "event_type": "first".jsonValue,
			"utc_time": "now".jsonValue,
			"firstPayload": "boo".jsonValue,
			"other": ["boo": "bar", "foo": "far"].jsonValue
		]
		XCTAssertEqual(expectedFirstEvent, batch.events.first)
		
		let expectedSecondEvent = [
			"event_id": "2".jsonValue, "event_type": "second".jsonValue,
			"utc_time": "now + 1".jsonValue,
			"secondPayload": "boo".jsonValue,
		]
		XCTAssertEqual(expectedSecondEvent, batch.events[1])
	}
	
	func test_buildBatch_from_one_event() {
		// arrange
		let firstEvent = EnrichedEvent(
			eventId: "1", name: "first", utcTime: "now", localTimezoneOffset: 3,
			payload: ["firstPayload": "boo".jsonValue],
			context: ["app_build_id": "1.1".jsonValue, "some": 3.jsonValue],
			userProperties: ["email": "test@test.test".jsonValue,
							 "other": ["boo": "bar", "foo": "far"].jsonValue
			]
		)

		// act
		let batch = BatchesController.buildBatch(unbatchedEvents: [firstEvent])
		
		// assert
		let expectedTemplate = [String: JSON]()
		XCTAssertEqual(expectedTemplate, batch.template)
		
		let expectedFirstEvent = [
			"app_build_id": "1.1".jsonValue,
			"some": 3.jsonValue,
			"email": "test@test.test".jsonValue,
			"local_tz_offset": 3.jsonValue,
			"event_id": "1".jsonValue, "event_type": "first".jsonValue,
			"utc_time": "now".jsonValue,
			"firstPayload": "boo".jsonValue,
			"other": ["boo": "bar", "foo": "far"].jsonValue
		]
		XCTAssertEqual(expectedFirstEvent, batch.events.first)
	}
	
}

