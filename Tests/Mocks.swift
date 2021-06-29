//
//  Mocks.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 29.06.2021.
//

import Foundation


class MockServiceLocator: ServiceLocator {
	var networkService: NetworkService = NetworkMock()
	var deviceInfoProvider: DeviceInfoProvider = DeviceInfoProviderMock()
	var storageLocator: StorageLocator = StorageLocatorMock()
}


class NetworkMock: NetworkService {
	required init(apiKey: String, host: String) {}
	init() {}
	
	func sendBatch(_ batch: EventsBatch, completion: @escaping SendBatchCompletion) {
		sendBatchBlock?(batch)
	}
	
	var sendBatchBlock: ((EventsBatch)-> Void)?
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
	func saveBatch(_ batch: EventsBatch) {
		
	}
	
	func removeBatch(with batchId: String) {
		
	}
}
