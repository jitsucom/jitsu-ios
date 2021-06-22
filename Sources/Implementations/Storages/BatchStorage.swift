//
//  BatchStorage.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

class BatchStorage {
	
	private var batches = [EventsBatch]()
	
	func saveBatch(_ batch: EventsBatch) {
		batches.append(batch)
	}
	
	func removeBatch(with batchId: String) {
		batches.removeAll { $0.batchId == batchId}
	}
}
