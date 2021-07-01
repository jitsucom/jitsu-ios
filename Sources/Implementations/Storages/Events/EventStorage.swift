//
//  EventStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation
import CoreData

protocol EventStorage {
	func loadEvents(_ completion: @escaping ([EnrichedEvent]) -> Void)
	func saveEvent(_ event: EnrichedEvent)
	func removeEvents(with eventIds: Set<String>)
}

class EventStorageImpl: EventStorage {
	private var coreDataStack: CoreDataStack
	
	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
	
	func loadEvents(_ completion: @escaping ([EnrichedEvent]) -> Void) {
		let context = coreDataStack.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<EnrichedEventMO> = EnrichedEventMO.fetchRequest()
		do {
			let result: [EnrichedEventMO] = try context.fetch(fetchRequest)
			print("fetched events: \(result.map {($0.name, $0.eventId)} )")
			let eventsFromDatabase = result.map { EnrichedEvent(eventMO: $0) }
			completion(eventsFromDatabase)
			
		} catch {
			print("\(#function) fetch failed")
			fatalError() //todo: remove later
			completion([])
		}
	}

	func saveEvent(_ event: EnrichedEvent) {
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		context.perform {
			let mo = EnrichedEventMO(context: context)
			mo.eventId = event.eventId
			mo.name = event.name
			mo.utcTime = event.utcTime
			mo.timezone = event.localTimezoneOffset
			mo.payload = NSDictionary(dictionary: event.payload)
			mo.context = NSDictionary(dictionary: event.context)
			mo.userProperties = NSDictionary(dictionary: event.userProperties)

			do {
				try context.save()
			} catch {
				print("\(#function) save failed: \(error)")
				fatalError()
			}
		}
	}
	
	func removeEvents(with eventIds: Set<String>) {
		print("\(#function) planning to remove \(eventIds)")
		
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		let fetchRequest: NSFetchRequest<EnrichedEventMO> = EnrichedEventMO.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "%K IN %@", "eventId", eventIds)
		do {
			let eventsToRemove = try context.fetch(fetchRequest)
			print("\(#function) fetched \(eventsToRemove.count)")
			
			for eventToRemove in eventsToRemove {
				context.delete(eventToRemove)
			}
			try context.save()
		} catch {
			print("oops")
			fatalError()
		}
		
	}
}

extension EnrichedEvent {
	init(eventMO: EnrichedEventMO) {
		self.init(
			eventId: eventMO.eventId,
			name: eventMO.name,
			utcTime: eventMO.utcTime,
			localTimezoneOffset: eventMO.timezone,
			payload: Dictionary(_immutableCocoaDictionary: eventMO.payload),
			context: Dictionary(_immutableCocoaDictionary: eventMO.context),
			userProperties: Dictionary(_immutableCocoaDictionary: eventMO.userProperties)
		)
	}
}
