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
		
			let batchesFromDatabase = result.map { Batch(batchMO: $0) }
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
			let mo = BatchMO(context: context)
			mo.batchId = batch.batchId
			mo.events = NSArray(array: batch.events)
			mo.template = NSDictionary(dictionary: batch.template)
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
	init(batchMO: BatchMO) {
		self.init(
			batchId: batchMO.batchId,
			events: Array(_immutableCocoaArray: batchMO.events),
			template: Dictionary(_immutableCocoaDictionary: batchMO.template)
		)
	}
}
