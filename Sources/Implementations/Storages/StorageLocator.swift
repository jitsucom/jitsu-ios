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
	var contextStorage: ContextStorage { get }
	var userPropertiesStorage: UserPropertiesStorage { get }
}

class StorageLocatorImpl: StorageLocator {
	lazy var stack = CoreDataStackImpl()
	
	lazy var eventStorage: EventStorage = {
		return EventStorageImpl(coreDataStack: stack)
	}()
	
	lazy var batchStorage: BatchStorage = {
		return BatchStorageImpl(coreDataStack: stack)
	}()
	
	lazy var contextStorage: ContextStorage = {
		return ContextStorageImpl(coreDataStack: stack)
	}()
	
	lazy var userPropertiesStorage: UserPropertiesStorage = {
		return UserPropertiesStorageImpl(coreDataStack: stack)
	}()
}
