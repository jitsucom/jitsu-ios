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

		let companyEntity = NSEntityDescription(from: EnrichedEventMO.self)
		companyEntity.addProperty(NSAttributeDescription(name: "eventId", ofType: .stringAttributeType))
		
		companyEntity.addProperty(NSAttributeDescription(name: "name", ofType: .stringAttributeType))
		companyEntity.addProperty(NSAttributeDescription(name: "utcTime", ofType: .stringAttributeType))
		companyEntity.addProperty(NSAttributeDescription(name: "payload", ofType: .transformableAttributeType, valueTransformerName: DictTransformer.name))
		
		companyEntity.addProperty(NSAttributeDescription(name: "context", ofType: .transformableAttributeType, valueTransformerName: DictTransformer.name))
		companyEntity.addProperty(NSAttributeDescription(name: "userProperties", ofType: .transformableAttributeType, valueTransformerName: DictTransformer.name))

		_model.entities = [companyEntity]
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
