//
//  JitsuClientImpl.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation


class JitsuClientImpl: JitsuClient {
	
	var context: JitsuContext
	var userProperties: UserProperties
	
	private var networkService: NetworkService
	private var storageLocator: StorageLocator
	
	private var eventsQueue = DispatchQueue(label: "com.jitsu.eventsQueue")
	
	init(deps: ServiceLocator) {
		self.networkService = deps.networkService
		self.storageLocator = deps.storageLocator
		
		let context = JitsuContextImpl(
			storage: storageLocator.contextStorage,
			deviceInfoProvider: deps.deviceInfoProvider
		)
		self.context = context
		
		let userProperties = JitsuUserPropertiesImpl()
		self.userProperties = userProperties
		userProperties.out = { [weak self] event in
			self?.trackEvent(event)
		}
		
		self.eventsQueue.async { [self] in
			let setupGroup = DispatchGroup()
			
			setupGroup.enter()
			context.setup {
				setupGroup.leave()
			}
			
			setupGroup.enter()
			userProperties.setup {
				setupGroup.leave()
			}
			
			eventsController.prepare()
			batchesController.prepare()
			
			setupGroup.wait()
		}
	}
	
	// MARK: - Events pipeline
	
	private lazy var eventsController: EventsController = {
		let eventsController = EventsController(
			storage: storageLocator.eventStorage,
			sendEvents: sendEventsOut
		)
		return eventsController
	}()
	
	func sendEventsOut(events: [EnrichedEvent], completion: @escaping SendEventsCompletion) {
		self.batchesController.processEvents(events, completion: completion)
	}
	
	private lazy var batchesController: BatchesController = {
		let batchesController = BatchesController(
			storage: storageLocator.batchStorage,
			sendBatch: sendBatchOut
		)
		return batchesController
	}()
	
	func sendBatchOut(batch: Batch, completion: @escaping SendBatchCompletion) {
		networkService.sendBatch(batch, completion: completion)
	}
		
	// MARK: - Tracking events
	
	func trackEvent(_ event: Event) {
		eventsQueue.async {
			
			self.eventsController.add(
				event: event,
				context: self.context.values(for: event.name),
				userProperties: self.userProperties.values()
			)
			
			if self.eventsController.unbatchedEventsCount >= self.eventsQueueSize {
				self.eventsController.sendEvents()
			}
		}
	}
	
	func trackEvent(name: EventType) {
		let event = JitsuBasicEvent(name: name)
		trackEvent(event)
	}
	
	func trackEvent(name: EventType, payload: [String : Any]) {
		let event = JitsuBasicEvent(name: name)
		event.payload = payload
		trackEvent(event)
	}
	
	// MARK: - Sendinng Batches
	
	var eventsQueueSize: Int = 2
	
	var sendingBatchesPeriod: TimeInterval = 10 // todo
	
	func sendBatch() {
		// todo
	}
	
	// MARK: - On/Off
	
	func turnOff() {
		
	}
	
	func turnOn() {
		
	}
	
}
