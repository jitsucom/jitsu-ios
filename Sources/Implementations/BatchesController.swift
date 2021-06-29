//
//  BatchesController.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 29.06.2021.
//

import Foundation

struct Batch {
	typealias BatchId = String
	
	var batchId: BatchId
	
	var events: [[String: Any]]
	var template: [String: Any]
}

typealias SendBatchCompletion = (Result<Batch.BatchId, NetworkServiceError>) -> Void
typealias SendBatch = (Batch, @escaping SendBatchCompletion) -> Void

class BatchesController {
	
	@Atomic private var unsentBatches = [Batch]()
	private var batchStorage: BatchStorage
	
	private var out: SendBatch
	
	init(storage: BatchStorage, sendBatch: @escaping SendBatch) {
		self.batchStorage = storage
		self.out = sendBatch
	}
	
	func prepare() {
		batchStorage.loadBatches { [weak self] unsentBatches in
			print("\(#function) loaded \(unsentBatches.count) batches")
			self?.unsentBatches.append(contentsOf: unsentBatches)
		}
	}
	
	func processEvents(_ events: [EnrichedEvent], completion: @escaping SendEventsCompletion) {
		let batch = buildBatch(unbatchedEvents: events)
		completion(true)
		
		unsentBatches.append(batch)
		batchStorage.saveBatch(batch)
		print("batch controller: sending \(batch.batchId)")
		out(batch) { [weak self] result in
			guard let self = self else {return}
			switch result {
			case .failure(let error):
				print(error)
			// todo retry
			case .success(let batchId):
				self.unsentBatches.removeAll { $0.batchId == batchId }
				self.batchStorage.removeBatch(with: batchId)
			}
		}
	}

	private func buildBatch(unbatchedEvents: [EnrichedEvent]) -> Batch {
		return Batch(
			batchId: UUID().uuidString,
			events: unbatchedEvents.map {$0.buildJson()},
			template: [:]
		)
	}
}
