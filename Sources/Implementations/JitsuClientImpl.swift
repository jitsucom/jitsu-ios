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
	
	private var eventTrackers = [Tracker<Event>]()
	private var contextTrackers = [Tracker<[String: String]>]()

	private func addTrackers() {
		let eventBlock: (Event) -> Void = { [weak self] event in
			guard let self = self else {return}
			self.trackEvent(event)
		}
		
		eventTrackers.append(ApplicationLifecycleTracker(callback: eventBlock))
		eventTrackers.append(UpdateTracker(callback: eventBlock))

		if options.shouldCaptureDeeplinks {
			eventTrackers.append(DeeplinkTracker(callback: eventBlock))
		}
		
		if options.shouldCapturePushEvents {
			eventTrackers.append(PushTracker(callback: eventBlock))
		}
		
		contextTrackers.append(AccessibilityTracker(callback: { [weak self] (newValue) in
			guard let self = self else {return}
			try? self.context.addValues(newValue, for: nil, persist: false)
		}))
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
	
	func trackEvent(name: EventType) {
		let event = JitsuBasicEvent(name: name)
		trackEvent(event)
	}
	
	func trackEvent(name: EventType, payload: [String : Any]) {
		let event = JitsuBasicEvent(name: name)
		event.payload = payload
		trackEvent(event)
	}
	
	func trackEvent(_ event: Event) {
		guard analyticsEnabled else {
			logInfo("analytics disabled, not tracking event")
			return
		}
		eventsQueue.async {
			self.eventsController.add(
				event: event,
				context: self.context.values(for: event.name),
				userProperties: self.userProperties.values()
			)
		}
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
	
	var isAnalyicsEnabledKey = "isAnalyicsEnabledKey"
	private var analyticsEnabled: Bool {
		let isEnabled = UserDefaults.standard.value(forKey: isAnalyicsEnabledKey) as? Bool
		
		if let isEnabled = isEnabled {
			return isEnabled
		}
		
		return true
	}
	
	func turnOff() {
		trackEvent(name: "Jitsu turned off")
		logCritical("Jitsu turned off")
		UserDefaults.standard.setValue(false, forKey: isAnalyicsEnabledKey)
	}
	
	func turnOn() {
		trackEvent(name: "Jitsu turned on")
		logCritical("Jitsu turned on")
		UserDefaults.standard.setValue(true, forKey: isAnalyicsEnabledKey)
	}
	
}
