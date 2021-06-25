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
	
	var payload: [String: Any]
	
	var context: [String: Any]
	var userProperties: [String: Any]
}

struct EventsBatch {
	typealias BatchId = String
	
	var batchId: BatchId
	
	var events: [EnrichedEvent]
	var template: [String: Any]
}

class EventsController {
	
	private var unbatchedEvents = [EnrichedEvent]()
	
	private var batchStorage: BatchStorage
	private var eventStorage: EventStorage
	
	private var networkService: NetworkService
	
	init(networkService: NetworkService) {
		self.batchStorage = BatchStorage()
		self.eventStorage = EventStorage()
		self.networkService = networkService
	}
	
	var unbatchedEventsCount: Int {
		return unbatchedEvents.count
	}
	
	func add(event: Event, context: JitsuContext, userProperties: UserProperties) {
		let enrichedEvent = EnrichedEvent(
			eventId: UUID().uuidString,
			name: event.name,
			utcTime: Date().utcTime,
			payload: event.payload,
			context: context.values(for: event.name),
			userProperties: userProperties.values()
		)
		
		unbatchedEvents.append(enrichedEvent)
		
		eventStorage.saveEvent(enrichedEvent)
	}
	
	func sendEvents() {
		let unbatchedEvents = self.unbatchedEvents
		self.unbatchedEvents.removeAll()
		let batch = createBatch(unbatchedEvents: unbatchedEvents)
		
		batchStorage.saveBatch(batch)
		eventStorage.removeEvents(with: unbatchedEvents.map{$0.eventId})
		
		networkService.sendBatch(batch) { [weak self] result in
			guard let self = self else {return}
			switch result {
			case .failure(let error):
				print(error)
				// todo retry
			case .success(let batchId):
				self.batchStorage.removeBatch(with: batchId)
			}
		}
	}
	
}


fileprivate func createBatch(unbatchedEvents: [EnrichedEvent]) -> EventsBatch {
	return EventsBatch(
		batchId: UUID().uuidString,
		events: unbatchedEvents,
		template: [:]
	)
}
