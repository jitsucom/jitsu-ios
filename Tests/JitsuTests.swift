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


class JitsuTests: XCTestCase {
	
	var sdk: JitsuClient!
	
    func testExample() throws {
		
		// arrange
		let options = JitsuOptions(
			apiKey: "s2s.kxp33.5shyyg0f7ryliseocab2oo",
			trackingHost: "t.jitsu.com/api/v1/event"
		)
		sdk = JitsuClientImpl(options: options)
		
		// act
		sdk.trackEvent(TestEvent(name: "test event"))
		
		// assert
		wait(for: [], timeout: 30)
		
	}

}
