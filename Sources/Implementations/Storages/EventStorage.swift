//
//  EventStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

class EventStorage {
	
	private var events = [EnrichedEvent]()
	
	func saveEvent(_ event: EnrichedEvent) {
		events.append(event)
	}
	
	func removeEvents(with eventIds: [String]) {
		let ids = Set(eventIds)
		events.removeAll { (event) -> Bool in
			ids.contains(event.eventId)
		}
	}
}
