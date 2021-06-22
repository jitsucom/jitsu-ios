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
	
	private var eventsController: EventsController
	
	required init(options: JitsuOptions) {
		self.context = JitsuContextImpl()
		self.userProperties = JitsuUserPropertiesImpl()
		
		let networkService = NetworkService (apiKey: options.apiKey, host: options.trackingHost!) // todo: fix force unwrap
		
		self.eventsController = EventsController(networkService: networkService)
	}
	
	// MARK: - Tracking events
	
	func trackEvent(_ event: Event) {
		eventsController.add(event: event, context: context, userProperties: userProperties)
		
		if eventsController.eventsCount > eventsQueueSize {
			eventsController.sendEvents()
		}
	}
	
	func trackEvent(name: EventType) {
		// calls trackEvent(_ event: Event)
	}
	
	func trackEvent(name: EventType, payload: [String : Any]) {
		// calls trackEvent(_ event: Event)
	}
	
	// MARK: - Sendinng Batches
	
	var eventsQueueSize: Int = 20
	
	var sendingBatchesPeriod: TimeInterval = 10
	
	func sendBatch() {
		
	}
	
	// MARK: - On/Off
	
	func turnOff() {
		
	}
	
	func turnOn() {
		
	}
	
}
