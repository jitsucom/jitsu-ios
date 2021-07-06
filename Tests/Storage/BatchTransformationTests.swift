//
//  CollectionsTransformationTests.swift
//  JitsuTests
//
//  Created by Leonid Serebryanyy on 05.07.2021.
//

import XCTest
@testable import Jitsu

class CollectionsTransformationTests: XCTestCase {
	
	func test_encoding_arrayOfDicts() throws {
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
		
		let batch = Batch(batchId: "123", events: [firstEvent, secondEvent], template: ["template" : "wow".jsonValue])
		
		let events = batch.events

		// serialize
		let str = try! JSON.toString(events)
		
		// deserialize
		let back = Batch.deserializeEvents(from: str)
		
		XCTAssertEqual(back, events)
	}
	
	func test_decoding_arrayOfDicts() throws {
		let str = "[{\"event_type\":\"first tracer bullet event\",\"utc_time\":\"2021-07-06T09:37:03Z\",\"first event payload\":\"\\\"boo\\\"\",\"event_id\":\"4753B21E-0CCA-422F-92BE-9BBC0818AB28\",\"local_tz_offset\":180},{\"app_build_id\":\"1.0\",\"event_type\":\"first tracer bullet event\",\"user_language\":\"en\",\"internal_id\":\"no value\",\"app_version_id\":\"1.0\",\"app_name\":\"ExampleApp\",\"sdk_version\":\"1.0\",\"src\":\"jitsu_ios\",\"anonymous_id\":\"5C2BDE04-34AE-4B90-A6A2-8F7A1B659FFE\",\"first event payload\":\"boo\",\"parsed_ua\":{\"os_family\":\"iOS\",\"device_model\":\"Simulator iPhone 7\",\"ua_family\":\"iPhone\",\"os_version\":\"14.3\",\"screen_resolution\":\"375.0x667.0\",\"device_brand\":\"Apple\"},\"local_tz_offset\":180,\"email\":\"no value\",\"event_id\":\"975BD119-0C99-45F5-A7E9-53F9187ABE5D\",\"utc_time\":\"2021-07-06T09:37:23Z\"}]"
		
		let result = try? JSON.toString(str)
		XCTAssertNotNil(result)
	}
}
