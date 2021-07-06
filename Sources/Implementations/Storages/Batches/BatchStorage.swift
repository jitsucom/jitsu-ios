//
//  BatchStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation
import CoreData

protocol BatchStorage {
	func loadBatches(_ completion: @escaping ([Batch]) -> Void)
	func saveBatch(_ batch: Batch)
	func removeBatch(with batchId: String)
}

class BatchStorageImpl: BatchStorage {
	private var coreDataStack: CoreDataStack
		
	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
	
	func loadBatches(_ completion: @escaping ([Batch]) -> Void) {
		let context = coreDataStack.persistentContainer.viewContext
		let fetchRequest: NSFetchRequest<BatchMO> = BatchMO.fetchRequest()
		do {
			let result: [BatchMO] = try context.fetch(fetchRequest)
			print("fetched batches: \(result.map{$0.batchId})")
		
			let batchesFromDatabase = result.map { Batch(mo: $0) }
			completion(batchesFromDatabase)
			
		} catch {
			print("\(#function) fetch failed")
			fatalError() //todo: remove later
			completion([])
		}
	}

	func saveBatch(_ batch: Batch) {
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		context.perform {
			BatchMO.createModel(with: batch, in: context)
			do {
				try context.save()
			} catch {
				print("\(#function) save failed: \(error)")
				fatalError()
			}
		}
	}
	
	func removeBatch(with batchId: String) {
		print("\(#function) planning to remove \(batchId)")
		let context = coreDataStack.persistentContainer.newBackgroundContext()
		let fetchRequest: NSFetchRequest<BatchMO> = BatchMO.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "%K = %@", "batchId", batchId)
		do {
			let batch = try context.fetch(fetchRequest)
			for b in batch {
				context.delete(b)
			}
			try context.save()
		} catch {
			print("oops")
			fatalError()
		}
	}
}

extension Batch {
	init(mo: BatchMO) {
		let events = Batch.deserializeEvents(from: mo.events)
		self.init(batchId: mo.batchId,
				  events: events,
				  template: [:])
	}
	
	static func deserializeEvents(from str: String) -> [[String: JSON]] {
		let eventsJSON = JSON.fromString(str)!
		let eventsJSONArray = eventsJSON.arrayValue!
		let new = eventsJSONArray.map { value -> [String: JSON] in
			let dict = value as! [String: Any]
			let jsonDict = dict.mapValues { try! JSON($0) }
			return jsonDict
		}
		return new
	}
}


extension BatchMO {
	@discardableResult
	static func createModel(with value: Batch, in context: NSManagedObjectContext) -> BatchMO {
		let mo = BatchMO(context: context)
		mo.batchId = value.batchId
		
		mo.events = try! JSON.toString(value.events)

		mo.template = try! JSON.toString(value.template)
		return mo
	}
}
