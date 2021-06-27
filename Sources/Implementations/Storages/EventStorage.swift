//
//  EventStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation
import CoreData


class EventStorage {
	private lazy var coreDataStack: CoreDataStack = {
		return CoreDataStack()
	}()
	
	init() {
		loadEvents()
	}
	
	private var events = [EnrichedEvent]()
	
	func loadEvents() {
		let context = coreDataStack.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<EnrichedEventMO> = EnrichedEventMO.fetchRequest()
		do {
			let result = try context.fetch(fetchRequest)
			print("fetched events: \(result)")
		} catch {
			print("failed")
		}
	}
		
	func saveEvent(_ event: EnrichedEvent) {
//		events.append(event)
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		context.perform {
			let event = EnrichedEventMO(context: context)
			event.name = "hi"
			do {
				try context.save()
			} catch {
				print("Failed to save event: \(error)")
			}
		}
	}
	
	func removeEvents(with eventIds: [String]) {
		let ids = Set(eventIds)
		events.removeAll { (event) -> Bool in
			ids.contains(event.eventId)
		}
	}
	
}

//extension EnrichedEventMOMD {
//	public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
//		<#code#>
//	}
//}
