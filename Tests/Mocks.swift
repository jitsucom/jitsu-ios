//
//  Mocks.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 29.06.2021.
//

import Foundation
@testable import Jitsu

class MockServiceLocator: ServiceLocator {
	var networkService: NetworkService = NetworkMock()
	var deviceInfoProvider: DeviceInfoProvider = DeviceInfoProviderMock()
	var storageLocator: StorageLocator = StorageLocatorMock()
	var timerService: RepeatingTimer = TimerMock()
}


class NetworkMock: NetworkService {
	required init(apiKey: String, host: String) {}
	init() {}
	
	func sendBatch(_ batch: Batch, completion: @escaping SendBatchCompletion) {
		sendBatchBlock?(batch)
	}
	
	var sendBatchBlock: ((Batch)-> Void)?
}


class DeviceInfoProviderMock: DeviceInfoProvider {
	var deviceInfo: DeviceInfo?
	
	func getDeviceInfo(_ completion: @escaping (DeviceInfo) -> Void) {
		completion(DeviceInfoProviderMock.mockDeviceInfo)
	}
	
	static let mockDeviceInfo = DeviceInfo(
		manufacturer: "Apple",
		deviceName: "iPhone",
		systemName: "iOS",
		systemVersion: "10",
		screenResolution: "1440x900"
	)
}


class StorageLocatorMock: StorageLocator {
	
	var eventStorage: EventStorage = EventStorageMock()
	
	var batchStorage: BatchStorage = BatchStorageMock()
	
	var contextStorage: ContextStorage = ContextStorageMock()
	
	var userPropertiesStorage: UserPropertiesStorage = UserPropertiesStorageMock()
}


class EventStorageMock: EventStorage {
	func loadEvents(_ completion: @escaping ([EnrichedEvent]) -> Void) {
		
	}
	
	func saveEvent(_ event: EnrichedEvent) {
		
	}
	
	func removeEvents(with eventIds: Set<String>) {
		
	}
}

class BatchStorageMock: BatchStorage {
	func loadBatches(_ completion: @escaping ([Batch]) -> Void) {
		
	}
	
	func saveBatch(_ batch: Batch) {
		
	}
	
	func removeBatch(with batchId: String) {
		
	}
}

class ContextStorageMock: ContextStorage {
	func loadContext() -> [ContextValue] {
		return []
	}
	
	func saveContextValue(_ value: ContextValue) {
		
	}
	
	func removeContextValue(_ value: ContextValue) {
		
	}

	func clear() {
		
	}
}

class UserPropertiesStorageMock: UserPropertiesStorage {
	func loadUserProperties() -> UserPropertiesModel? {
		return nil
	}
	
	func saveUserPropertiesModel(_ value: UserPropertiesModel) {
		
	}
	
	func removeUserPropertiesModel(_ value: UserPropertiesModel) {
		
	}
	
	func clear() {
		
	}
}

class TimerMock: RepeatingTimer {
	
	var fireBlock: TimerBlock?
	var cancelBlock: TimerBlock?
	var setBlock: (() -> Void)?
	
	func set(time: TimeInterval, fireBlock: @escaping TimerBlock) {
		self.fireBlock = fireBlock
		setBlock?()
	}
	
	func cancel() {
		cancelBlock?(self)
	}
	
	func fire() {
		fireBlock?(self)
	}
}
