//
//  EventsStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

typealias SendEventsCompletion = (Bool) -> Void
typealias SendEvents = ([EnrichedEvent], @escaping SendEventsCompletion) -> Void

class EventsController {
	
	private(set) var eventsQueueSize: Int = 10
	private(set) var sendingBatchesPeriod: TimeInterval = 5
	
	@Atomic private var unbatchedEvents = [EnrichedEvent]()
	
	private var eventStorage: EventStorage
	private var out: SendEvents
	private var timer: RepeatingTimer

	init(storage: EventStorage, timer: RepeatingTimer, sendEvents: @escaping SendEvents) {
		self.eventStorage = storage
		self.out = sendEvents
		self.timer = timer
	}
	
	deinit {
		
	}
	
	func prepare() {
		resetTimer()
		eventStorage.loadEvents { [weak self] storedEvents in
			print("\(#function) loaded \(storedEvents.count) events")
			self?.$unbatchedEvents.mutate {$0.append(contentsOf: storedEvents)}
		}
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
		$unbatchedEvents.mutate {$0.append(enrichedEvent)}
		eventStorage.saveEvent(enrichedEvent)
		
		if $unbatchedEvents.value.count >= self.eventsQueueSize {
			sendEvents()
		}
	}
	
	func sendEvents() {
		if $unbatchedEvents.value.count == 0 {
			print("events controller: zero events)")
			return
		}
		
		resetTimer()
		
		print("events controller: passing \(unbatchedEvents.map{$0.name})")
		let batchEventIds = Set(unbatchedEvents.map {$0.eventId})
		$unbatchedEvents.mutate { state in
			state.removeAll { batchEventIds.contains($0.eventId) }
		}
		
		out(unbatchedEvents) {[weak self] success in
			if success {
				self?.eventStorage.removeEvents(with: batchEventIds)
			} else {
				
			}
		}
	}
	
	func setEventsQueueSize(_ value: Int) {
		eventsQueueSize = value
		if unbatchedEvents.count >= eventsQueueSize {
			sendEvents()
		}
	}
	
	func setSendingBatchesPeriod(_ value: TimeInterval) {
		sendingBatchesPeriod = value
		resetTimer()
	}
	
	func resetTimer() {
		timer.cancel()
		timer.set(time: sendingBatchesPeriod) {[weak self] _ in
			self?.sendEvents()
		}
	}
	
}


