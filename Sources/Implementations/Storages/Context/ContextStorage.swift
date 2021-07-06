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
	
	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
	
	func loadContext() -> [ContextValue] {
		let context = coreDataStack.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<ContextMO> = ContextMO.fetchRequest()
		do {
			let result: [ContextMO] = try context.fetch(fetchRequest)
			let databaseValues = result.map { ContextValue(contextMO: $0) }
			print("fetched contextValues: \(databaseValues.map {($0.key, $0.value, $0.eventType)} )")
			return databaseValues
		} catch {
			print("\(#function) fetch failed")
			fatalError() //todo: remove later
			return []
		}
	}
	
	func saveContextValue(_ value: ContextValue) {
		print("\(#function) saving contextValue: \(value)")
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		removeContextValue(value, context: context)
		context.perform {
			ContextMO.createModel(with: value, in: context)
			do {
				try context.save()
			} catch {
				print("\(#function) save failed: \(error)")
				fatalError()
			}
		}
	}
	
	func removeContextValue(_ value: ContextValue) {
		print("\(#function) planning to remove \(value.key) for event type \(value.eventType ?? "nil")")
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		removeContextValue(value, context: context)
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
				print("\(#function) deleting \(b.key) \(b.eventType ?? "general") \(b.value)")
				context.delete(b)
			}
			try context.save()
		} catch {
			print("oops")
			fatalError()
		}
	}
	
	func clear() {
		print("\(#function)")
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		let fetchRequest: NSFetchRequest<ContextMO> = ContextMO.fetchRequest()
		do {
			let valuesToRemove = try context.fetch(fetchRequest)
			print("\(#function) fetched \(valuesToRemove.count)")
			
			for value in valuesToRemove {
				context.delete(value)
			}
			try context.save()
		} catch {
			print("oops")
			fatalError()
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
