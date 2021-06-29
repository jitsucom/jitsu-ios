//
//  BatchStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

protocol BatchStorage {
	func saveBatch(_ batch: EventsBatch)
	func removeBatch(with batchId: String) 
}

class BatchStorageImpl: BatchStorage {
	
	private var batches = [EventsBatch]()
	
	func saveBatch(_ batch: EventsBatch) {
		batches.append(batch)
	}
	
	func removeBatch(with batchId: String) {
		batches.removeAll { $0.batchId == batchId}
	}
}
