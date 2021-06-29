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

struct EventsBatch {
	typealias BatchId = String
	
	var batchId: BatchId
	
	var events: [[String: Any]]
	var template: [String: Any]
}

class EventsController {
	
	@Atomic private var unbatchedEvents = [EnrichedEvent]()
	@Atomic private var unsentBatches = [EventsBatch]()
	
	private var batchStorage: BatchStorage
	private var eventStorage: EventStorage
	
	private var networkService: NetworkService
	
	init(networkService: NetworkService, storage: StorageLocator) {
		self.batchStorage = storage.batchStorage
		self.eventStorage = storage.eventStorage
		self.networkService = networkService
		
		eventStorage.loadEvents { [weak self] storedEvents in
			self?.unbatchedEvents.append(contentsOf: storedEvents)
		}
		
		batchStorage.loadBatches { [weak self] unsentBatches in
			self?.unsentBatches.append(contentsOf: unsentBatches)
		}
	}
	
	var unbatchedEventsCount: Int {
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
		let unbatchedEvents = self.unbatchedEvents
		self.unbatchedEvents.removeAll()
		let batch = createBatch(unbatchedEvents: unbatchedEvents)
		unsentBatches.append(batch)
		
		batchStorage.saveBatch(batch)
		removeEvents(with: unbatchedEvents.map { $0.eventId } )
		
		networkService.sendBatch(batch) { [weak self] result in
			guard let self = self else {return}
			switch result {
			case .failure(let error):
				print(error)
				// todo retry
			case .success(let batchId):
				self.unsentBatches.removeAll { $0.batchId == batchId }
				self.batchStorage.removeBatch(with: batchId)
			}
		}
	}
	
	func removeEvents(with eventIds: [String]) {
		print("planning to remove \(eventIds)")
		let ids = Set(eventIds)
		unbatchedEvents.removeAll { (event) -> Bool in
			ids.contains(event.eventId)
		}
		eventStorage.removeEvents(with: ids)
	}
	
}

func createBatch(unbatchedEvents: [EnrichedEvent]) -> EventsBatch {
	return EventsBatch(
		batchId: UUID().uuidString,
		events: unbatchedEvents.map {$0.buildJson()},
		template: [:]
	)
}

