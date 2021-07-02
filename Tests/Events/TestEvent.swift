//
//  TestEvent.swift
//  JitsuTests
//
//  Created by Leonid Serebryanyy on 01.07.2021.
//

import Foundation
@testable import Jitsu

class TestEvent: Event {
	var name: EventType
	
	var payload = [String : Any]()
	
	init(_ name: EventType) {
		self.name = name
	}
	
	convenience init() {
		self.init("test")
	}
}
