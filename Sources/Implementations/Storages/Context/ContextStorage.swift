//
//  ContextStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 29.06.2021.
//

import Foundation
import CoreData

protocol ContextStorage {
	func loadContext() -> [ContextValue]
	func saveContextValue(_ value: ContextValue)
	func removeContextValue(_ value: ContextValue)
	func clear()
}

class ContextStorageImpl: ContextStorage {
	private var coreDataStack: CoreDataStack
	private lazy var context = coreDataStack.persistentContainer.newBackgroundContext()

	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
	
	func loadContext() -> [ContextValue] {
		let context = coreDataStack.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<ContextMO> = ContextMO.fetchRequest()
		do {
			let result: [ContextMO] = try context.fetch(fetchRequest)
			let databaseValues = result.map { ContextValue(contextMO: $0) }
			logInfo(
				"\(#function) fetched \(databaseValues.map {($0.key, $0.value, $0.eventType)} )"
			)

			return databaseValues
		} catch {
			logCritical("\(#function) load failed, \(error)")
			return []
		}
	}
	
	func saveContextValue(_ value: ContextValue) {
		logInfo("\(#function) saving contextValue: \(value)")
		context.perform { [self] in
			self.removeContextValue(value, context: context)
			ContextMO.createModel(with: value, in: context)
			do {
				print("===saving===")
				try context.save()
			} catch {
				logCritical("\(#function) save failed: \(error)")
			}
		}
	}
	
	func removeContextValue(_ value: ContextValue) {
		logInfo("\(#function) planning to remove \(value.key) for event type \(value.eventType ?? "nil")")
		context.perform { [self] in
			removeContextValue(value, context: context)
			try! context.save()
		}
	}
	
	func removeContextValue(_ value: ContextValue, context: NSManagedObjectContext) {
		let fetchRequest: NSFetchRequest<ContextMO> = ContextMO.fetchRequest()
		fetchRequest.predicate = NSCompoundPredicate(
			andPredicateWithSubpredicates: [
				NSPredicate(format: "%K = %@", "key", value.key),
				NSPredicate(format: "%K = %@", "eventType", value.eventType ?? ContextMO.genericEvent),
			])
		
		do {
			let params = try context.fetch(fetchRequest)
			for b in params {
				logDebug("\(#function) deleting value for key: \(b.key) with eventType: \(b.eventType ?? "general") value: \(b.value)")
				context.delete(b)
			}
		} catch {
			logCriticalFrom(self, "\(#function) remove failed")
		}
	}
	
	func clear() {
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		let fetchRequest: NSFetchRequest<ContextMO> = ContextMO.fetchRequest()
		do {
			let valuesToRemove = try context.fetch(fetchRequest)
			logDebug("\(#function) fetched \(valuesToRemove.count)")
			
			for value in valuesToRemove {
				context.delete(value)
			}
			try context.save()
		} catch {
			logCriticalFrom(self, "\(#function) clear failed")
		}
	}
}

extension ContextValue {
	init(contextMO: ContextMO) {
		var eventType = contextMO.eventType
		if eventType == ContextMO.genericEvent {
			eventType = nil
		}
		self.init(
			key: contextMO.key,
			value: JSON.fromString(contextMO.value) ?? "decoding failed".jsonValue,
			eventType: eventType
		)
	}
}

extension ContextMO {
	@discardableResult
	static func createModel(with value: ContextValue, in context: NSManagedObjectContext) -> ContextMO {
		let mo = ContextMO(context: context)
		mo.key = value.key
		mo.value = value.value.toString()
		mo.eventType = value.eventType ?? ContextMO.genericEvent
		return mo
	}
}
