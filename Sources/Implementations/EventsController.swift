//
//  EventsStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

struct EnrichedEvent {
	typealias EventId = String
	
	var eventId: EventId
	
	var name: String
	
	var utcTime: String
	var localTimezoneOffset: Int
	
	var payload: [String: Any]
	
	var context: [String: Any]
	
	var userProperties: [String: Any]
	
	func buildJson() -> [String: Any] {
		var dict: [String: Any] = [
			"event_id": eventId,
			"event_type": name,
			
			"utc_time": utcTime,
			"local_tz_offset": localTimezoneOffset,
		]
		
		dict.merge(payload) { (val1, val2) in return val1 }
		dict.merge(userProperties) { (val1, val2) in return val1 }
		dict.merge(context) { (val1, val2) in return val1 }
		
		return dict
	}
}

typealias SendEventsCompletion = (Bool) -> Void
typealias SendEvents = ([EnrichedEvent], @escaping SendEventsCompletion) -> Void

class EventsController {
	
	@Atomic private var unbatchedEvents = [EnrichedEvent]()
	private var eventStorage: EventStorage
	
	private var out: SendEvents

	init(storage: EventStorage, sendEvents: @escaping SendEvents) {
		self.eventStorage = storage
		self.out = sendEvents
	}
	
	func prepare() {
		eventStorage.loadEvents { [weak self] storedEvents in
			self?.unbatchedEvents.append(contentsOf: storedEvents)
		}
	}
	
	var unbatchedEventsCount: Int { // todo: make private
		return unbatchedEvents.count
	}
	
	func add(event: Event, context: [String : Any], userProperties: [String : Any]) {
		print("dbg adding event \(event.name), context \(context), userProperties \(userProperties)")

		let enrichedEvent = EnrichedEvent(
			eventId: UUID().uuidString,
			name: event.name,
			utcTime: Date().utcTime,
			localTimezoneOffset: Date().minutesFromUTC,
			payload: event.payload,
			context: context,
			userProperties: userProperties
		)
		
		unbatchedEvents.append(enrichedEvent)
		
		eventStorage.saveEvent(enrichedEvent)
	}
	
	func sendEvents() {
		let batchEventIds = Set(unbatchedEvents.map {$0.eventId})
		unbatchedEvents.removeAll { batchEventIds.contains($0.eventId) }
		
		out(unbatchedEvents) {[weak self] success in
			if success {
				self?.eventStorage.removeEvents(with: batchEventIds)
			} else {
				// todo: retry?
			}
		}
	}
	
}


