//
//  ManualCoreData.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 27.06.2021.
//

import Foundation
import CoreData


class CoreDataStack: NSObject {
	
	var model: NSManagedObjectModel {
		let _model = NSManagedObjectModel()
		
		ValueTransformer.setValueTransformer(DictTransformer(), forName: DictTransformer.name)
		ValueTransformer.setValueTransformer(ArrayTransformer(), forName: ArrayTransformer.name)
		
		_model.entities = [
			EnrichedEventMO.eventEntity,
			BatchMO.batchEntity,
		]
		return _model
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let _container = NSPersistentContainer(name: "Jitsu", managedObjectModel: model)
		_container.loadPersistentStores {
			(description, error) in
			
		}
		return _container
	}()
}


@objc final class DictTransformer: NSSecureUnarchiveFromDataTransformer {
	override class func transformedValueClass() -> AnyClass {
		return NSDictionary.self
	}

	override class func allowsReverseTransformation() -> Bool {
		return true
	}
	
	static let name = NSValueTransformerName(rawValue: "DictTransformer")
}


@objc final class ArrayTransformer: NSSecureUnarchiveFromDataTransformer {
	override class func transformedValueClass() -> AnyClass {
		return ArrayTransformer.self
	}
	
	override class func allowsReverseTransformation() -> Bool {
		return true
	}
	
	static let name = NSValueTransformerName(rawValue: "ArrayTransformer")
}
