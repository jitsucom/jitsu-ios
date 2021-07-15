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
	private var deps: ServiceLocator
	private var options: JitsuOptions
	
	private var eventsQueue = DispatchQueue(label: "com.jitsu.eventsQueue")
	
	init(options: JitsuOptions, deps: ServiceLocator) {
		self.options = options
		self.deps = deps
		self.networkService = deps.networkService
		self.storageLocator = deps.storageLocator
		
		let context = JitsuContextImpl(
			storage: storageLocator.contextStorage,
			deviceInfoProvider: deps.deviceInfoProvider
		)
		self.context = context
		
		let userProperties = JitsuUserPropertiesImpl(storage: storageLocator.userPropertiesStorage)
		self.userProperties = userProperties
		userProperties.out = { [weak self] event in
			self?.trackEvent(event)
		}
		
		addTrackers()
		
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
	
	private var trackers = [Tracker]()
	
	private func addTrackers() {
		let eventBlock: (Event) -> Void = { [weak self] event in
			guard let self = self else {return}
			self.trackEvent(event)
		}
		trackers.append(ApplicationLifecycleTracker.subscribe(eventBlock))
		trackers.append(UpdateTracker.subscribe(eventBlock))
		
		if options.shouldCaptureDeeplinks {
			trackers.append(DeeplinkTracker.subscribe(eventBlock))
		}
		if options.shouldCapturePushEvents {
			trackers.append(PushTracker.subscribe(eventBlock))
		}
	}
	
	// MARK: - Events pipeline
	
	private lazy var eventsController: EventsController = {
		let eventsController = EventsController(
			storage: storageLocator.eventStorage,
			timer: deps.timerService,
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
	
	var eventsQueueSize: Int {
		set {
			eventsController.setEventsQueueSize(newValue)
		} get {
			eventsController.eventsQueueSize
		}
	}
	
	var sendingBatchesPeriod: TimeInterval {
		set {
			eventsController.setSendingBatchesPeriod(newValue)
		} get {
			eventsController.sendingBatchesPeriod
		}
	}
	
	func sendBatch() {
		eventsController.sendEvents()
	}
	
	// MARK: - On/Off
	
	func turnOff() {
		
	}
	
	func turnOn() {
		
	}
	
}
