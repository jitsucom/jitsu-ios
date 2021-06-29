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
	private lazy var coreDataStack: CoreDataStack = {
		return CoreDataStack()
	}()
	
	func loadEvents(_ completion: @escaping ([EnrichedEvent]) -> Void) {
		let context = coreDataStack.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<EnrichedEventMO> = EnrichedEventMO.fetchRequest()
		do {
			let result: [EnrichedEventMO] = try context.fetch(fetchRequest)
			print("fetched events: ")
			result.forEach {
				print($0.name)
			}
			let eventsFromDatabase = result.map {
				EnrichedEvent(eventMO: $0)
			}
			completion(eventsFromDatabase)
			
		} catch {
			print("\(#function) events fetch failed")
			fatalError() //todo: remove later
			completion([])
		}
	}

	func saveEvent(_ event: EnrichedEvent) {
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		context.perform {
			let eventMO = EnrichedEventMO(context: context)
			eventMO.eventId = event.eventId
			eventMO.name = event.name
			eventMO.utcTime = event.utcTime
			eventMO.timezone = event.localTimezoneOffset
			eventMO.payload = NSDictionary(dictionary: event.payload)
			eventMO.context = NSDictionary(dictionary: event.context)
			eventMO.userProperties = NSDictionary(dictionary: event.userProperties)

			do {
				try context.save()
			} catch {
				print("Failed to save event: \(error)")
				fatalError()
			}
		}
	}
	
	func removeEvents(with eventIds: Set<String>) {
		print("planning to remove \(eventIds)")
		
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		let fetchRequest: NSFetchRequest<EnrichedEventMO> = EnrichedEventMO.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "%K IN %@", "eventId", eventIds)
		
		do {
			let eventsToRemove = try context.fetch(fetchRequest)
			print("fetched \(eventsToRemove.count)")
			
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
