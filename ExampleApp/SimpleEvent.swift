//
//  SimpleEvent.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 08.07.2021.
//

import Foundation
import Jitsu

class SimpleEvent: Event {
	var name: EventType
	
	var payload = [String : Any]()
	
	init(_ name: EventType, payload: [String : Any]?) {
		self.name = name
		self.payload = payload ?? [:]
	}
}
