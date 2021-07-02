//
//  JitsuServiceLocator.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 29.06.2021.
//

import Foundation

protocol ServiceLocator {
	
	var networkService: NetworkService {get}
	
	var deviceInfoProvider: DeviceInfoProvider {get}
	
	var storageLocator: StorageLocator {get}
	
	var timerService: RepeatingTimer {get}
}

class ServiceLocatorImpl: ServiceLocator {
	
	private var options: JitsuOptions
	
	init(options: JitsuOptions) {
		self.options = options
	}
	
	lazy var networkService: NetworkService = NetworkServiceImpl(apiKey: options.apiKey, host: options.trackingHost)
	
	lazy var deviceInfoProvider: DeviceInfoProvider = DeviceInfoProviderImpl()
	
	lazy var storageLocator: StorageLocator = StorageLocatorImpl()
	
	lazy var timerService: RepeatingTimer = RepeatingTimerI()

}
