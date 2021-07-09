//
//  BatchesController.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 29.06.2021.
//

import Foundation

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
			unsentBatches.forEach {
				self?.sendBatch($0)
			}
		}
	}
	
	func processEvents(_ events: [EnrichedEvent], completion: @escaping SendEventsCompletion) {
		let batch = Self.buildBatch(unbatchedEvents: events)
		completion(true)
		
		unsentBatches.append(batch)
		batchStorage.saveBatch(batch)
		
		sendBatch(batch)
	}
	
	private func sendBatch(_ batch: Batch) {
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

	static func buildBatch(unbatchedEvents: [EnrichedEvent]) -> Batch {
		return Batch(
			batchId: UUID().uuidString,
			events: unbatchedEvents,
			template: [:]
		)
	}
}
