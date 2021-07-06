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
	@NSManaged public var events: String
	@NSManaged public var template: String
}
//
extension BatchMO {
	static let batchEntity: NSEntityDescription = {
		let entity = NSEntityDescription(from: BatchMO.self)
		
		entity.addProperty(NSAttributeDescription(name: "batchId", ofType: .stringAttributeType))
		
		entity.addProperty(NSAttributeDescription(name: "events", ofType: .stringAttributeType))
		
		entity.addProperty(NSAttributeDescription(name: "template", ofType: .stringAttributeType))
		
		return entity
	}()
}

extension BatchMO {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<BatchMO> {
		return NSFetchRequest<BatchMO>(entityName: NSStringFromClass(self))
	}
}

extension BatchMO : Identifiable {}


