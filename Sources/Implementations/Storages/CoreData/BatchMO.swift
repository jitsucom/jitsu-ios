//
//  BatchMO.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 29.06.2021.
//

import Foundation
import CoreData

@objc(BatchMO)
public class BatchMO: NSManagedObject {
	
	@NSManaged public var batchId: String
	@NSManaged public var events: NSArray
	@NSManaged public var template: NSDictionary
}

extension BatchMO {
	static let batchEntity: NSEntityDescription = {
		let entity = NSEntityDescription(from: BatchMO.self)
		
		entity.addProperty(NSAttributeDescription(name: "batchId", ofType: .stringAttributeType))
		
		entity.addProperty(NSAttributeDescription(name: "events", ofType: .transformableAttributeType, valueTransformerName: ArrayTransformer.name))
		
		entity.addProperty(NSAttributeDescription(name: "template", ofType: .transformableAttributeType, valueTransformerName: DictTransformer.name))
		
		return entity
	}()
}

extension BatchMO {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<BatchMO> {
		return NSFetchRequest<BatchMO>(entityName: NSStringFromClass(self))
	}
	
}

extension BatchMO : Identifiable {}


