//
//  EventsControllerTests.swift
//  JitsuTests
//
//  Created by Leonid Serebryanyy on 01.07.2021.
//

import XCTest
@testable import Jitsu


class EventsControllerTests: XCTestCase {
	var controller: EventsController!
	
	var storage = EventStorageMock()
	var timer = RepeatingTimerI()

    override func setUpWithError() throws {
    }
	
	func test_timer() throws {
		// arrange
		let timerFires = XCTestExpectation()
		
		controller = EventsController(storage: storage, timer: timer) { (events, completion) in
			timerFires.fulfill()
		}
		controller.add(event: TestEvent(), context: [:], userProperties: [:])
		controller.setSendingBatchesPeriod(1)
		
		// act
		controller.prepare()
		
		//assert
		self.wait(for: [timerFires], timeout: 2)
	}
	
	func test_timer_resets() throws {
		// arrange
		let timerFires = XCTestExpectation()
		timerFires.expectedFulfillmentCount = 2
		
		controller = EventsController(storage: storage, timer: timer) { (events, completion) in
			timerFires.fulfill()
			self.controller.add(event: TestEvent(), context: [:], userProperties: [:])
		}
		controller.add(event: TestEvent(), context: [:], userProperties: [:])
		controller.setSendingBatchesPeriod(1)
		
		// act
		controller.prepare()
		
		//assert
		self.wait(for: [timerFires], timeout: 4)
	}
	
	func test_timer_isResettedWhenEventsAreSent() throws {
		// arrange
		let eventsAreSent = XCTestExpectation(description: "sent")
		let timerWasCancelled = XCTestExpectation(description: "cancelled")
		let timerSet = XCTestExpectation(description: "timerSet")
		timerSet.expectedFulfillmentCount = 2
		
		let timer = TimerMock()
		timer.cancelBlock = {_ in timerWasCancelled.fulfill() }
		timer.setBlock = { timerSet.fulfill()}
		controller = EventsController(storage: storage, timer: timer) { (events, completion) in
			eventsAreSent.fulfill()
		}
		controller.setSendingBatchesPeriod(1)
		controller.add(event: TestEvent(), context: [:], userProperties: [:])
		
		// act
		controller.prepare()
		controller.sendEvents()
		
		//assert
		self.wait(for: [eventsAreSent, timerWasCancelled, timerSet], timeout: 2)
	}
	
	func test_timer_valueChanges() throws {
		// arrange
		let timerWasCancelled = XCTestExpectation(description: "cancelled")
		let timerSet = XCTestExpectation(description: "timerSet")
		timerSet.expectedFulfillmentCount = 2
		
		let timer = TimerMock()
		timer.cancelBlock = {_ in timerWasCancelled.fulfill() }
		timer.setBlock = { timerSet.fulfill()}
		controller = EventsController(storage: storage, timer: timer) { _,_ in}
		
		// act
		controller.prepare()
		controller.setSendingBatchesPeriod(1)
		
		//assert
		self.wait(for: [timerWasCancelled, timerSet], timeout: 2)
	}
	
	func test_queueSize() throws {
		// arrange
		let eventsSent = XCTestExpectation()
		
		controller = EventsController(storage: storage, timer: timer) { events, _ in
			eventsSent.fulfill()
		}
		controller.setEventsQueueSize(2)
		
		// act
		controller.add(event: TestEvent(), context: [:], userProperties: [:])
		controller.add(event: TestEvent(), context: [:], userProperties: [:])
		
		//assert
		self.wait(for: [eventsSent], timeout: 0)
	}
	
	func test_queueSize_valueChanges() throws {
		// arrange
		let eventsSent = XCTestExpectation()
		eventsSent.isInverted = true
		
		controller = EventsController(storage: storage, timer: timer) { events, _ in
			eventsSent.fulfill()
		}
		controller.setEventsQueueSize(2)
		
		// act
		controller.add(event: TestEvent(), context: [:], userProperties: [:])
		controller.setEventsQueueSize(3)
		controller.add(event: TestEvent(), context: [:], userProperties: [:])
		
		//assert
		self.wait(for: [eventsSent], timeout: 0)
	}
	
}
