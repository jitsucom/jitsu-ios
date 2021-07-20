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
			logInfo("fetched events: \(result.map {($0.name, $0.eventId)} )")
			let eventsFromDatabase = result.map { EnrichedEvent(mo: $0) }
			completion(eventsFromDatabase)
			
		} catch {
			logCritical("\(#function) load failed, \(error)")
			completion([])
		}
	}
	
	func saveEvent(_ event: EnrichedEvent) {
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		context.perform {
			EnrichedEventMO.createModel(with: event, in: context)
			do {
				try context.save()
			} catch {
				logCritical("\(#function) save failed: \(error)")
			}
		}
	}
	
	func removeEvents(with eventIds: Set<String>) {
		logDebug("\(#function) planning to remove \(eventIds)")
		
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		let fetchRequest: NSFetchRequest<EnrichedEventMO> = EnrichedEventMO.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "%K IN %@", "eventId", eventIds)
		do {
			let eventsToRemove = try context.fetch(fetchRequest)
			logDebug("\(#function) will remove \(eventsToRemove.count) events")
			
			for eventToRemove in eventsToRemove {
				context.delete(eventToRemove)
			}
			try context.save()
		} catch {
			logCriticalFrom(self, "\(#function) remove failed")
		}
		
	}
}

extension EnrichedEvent {
	init(mo: EnrichedEventMO) {
		self.init(
			eventId: mo.eventId,
			name: mo.name,
			utcTime: mo.utcTime,
			localTimezoneOffset: mo.timezone,
			payload: try! (mo.payload as! [String: String]).mapValues {try JSON($0)},
			context: try! (mo.context as! [String: String]).mapValues {try JSON($0)},
			userProperties: try! (mo.userProperties as! [String: String]).mapValues {try JSON($0)}
		)
	}
}

extension EnrichedEventMO {
	@discardableResult
	static func createModel(with event: EnrichedEvent, in context: NSManagedObjectContext) -> EnrichedEventMO {
		let mo = EnrichedEventMO(context: context)
		mo.eventId = event.eventId
		mo.name = event.name
		mo.utcTime = event.utcTime
		mo.timezone = event.localTimezoneOffset
		mo.payload = event.payload.mapValues { $0.toString() } as NSDictionary
		mo.context = event.context.mapValues { $0.toString() } as NSDictionary
		mo.userProperties = event.userProperties.mapValues { $0.toString() } as NSDictionary
		
		return mo
	}
}
