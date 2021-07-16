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
			logInfo("\(#function) loaded \(unsentBatches.count) batches")
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
		logInfo("batch controller: sending \(batch.batchId)")
		out(batch) { [weak self] result in
			guard let self = self else {return}
			switch result {
			case .failure(let error):
				logError(error.errorDescription)
			case .success(let batchId):
				self.unsentBatches.removeAll { $0.batchId == batchId }
				self.batchStorage.removeBatch(with: batchId)
			}
		}
	}

	static func buildBatch(unbatchedEvents: [EnrichedEvent]) -> Batch {
		guard let firstEvent = unbatchedEvents.first, unbatchedEvents.count > 1 else {
			return Batch(
				batchId: UUID().uuidString,
				events: unbatchedEvents,
				template: [:]
			)
		}
		
		let firstTemplateCandidate = makeTemplateCandidate(firstEvent)
				
		let template: Set<TemplateValue> = unbatchedEvents.reduce(
			firstTemplateCandidate
		) { nextPartialResult, nextEvent in
			let nextEventCandidates = makeTemplateCandidate(nextEvent)
			return nextPartialResult.intersection(nextEventCandidates)
		}
		
		let templateDict: [String: JSON] = template.reduce(into: [String: JSON](), { (res, cand) in
			res[cand.key] = cand.value
		})
		
		let eventJsons = unbatchedEvents.map {substractTemplate(template, from: $0.buildJson())}
	
		return Batch(
			batchId: UUID().uuidString,
			events: eventJsons,
			template: templateDict
		)
	}
	
	static private func substractTemplate(_ template: Set<TemplateValue>, from eventDict: [String: JSON]) -> [String: JSON] {
		var eventValues = Set(eventDict.map { TemplateValue(key: $0.key, value: $0.value) })
		eventValues.subtract(template)
		return eventValues.reduce(into: [String: JSON](), { (res, cand) in
			res[cand.key] = cand.value
		})
	}
}

fileprivate struct TemplateValue: Hashable, Equatable {
	var key: String
	var value: JSON
}

fileprivate func makeTemplateCandidate(_ event: EnrichedEvent) -> Set<TemplateValue> {
	return Set(event.buildJson().map { TemplateValue(key: $0.key, value: $0.value) })
}

