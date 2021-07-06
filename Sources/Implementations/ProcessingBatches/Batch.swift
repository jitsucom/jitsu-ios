//
//  Batch.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 03.07.2021.
//

import Foundation

struct Batch {
	
	typealias BatchId = String
	
	var batchId: BatchId
	
	var events: [[String: JSON]]
	var template: [String: JSON]
	
	init(batchId: Batch.BatchId, events: [EnrichedEvent], template: [String : JSON]) {
		self.batchId = batchId
		self.events = events.map { event in
			event.buildJson()
		}
		self.template = template
	}
	
	init(batchId: Batch.BatchId, events: [[String: JSON]], template: [String : JSON]) {
		self.batchId = batchId
		self.events = events
		self.template = template
	}
}
