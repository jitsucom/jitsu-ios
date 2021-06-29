//
//  StorageLocator.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 29.06.2021.
//

import Foundation


protocol StorageLocator {
	var eventStorage: EventStorage { get }
	var batchStorage: BatchStorage { get }
}


class StorageLocatorImpl: StorageLocator {
	lazy var eventStorage: EventStorage = {
		return EventStorageImpl()
	}()
	
	lazy var batchStorage: BatchStorage = {
		return BatchStorageImpl()
	}()
	
	
}
