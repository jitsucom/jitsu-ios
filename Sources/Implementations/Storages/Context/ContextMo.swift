//
//  ContextMo.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 30.06.2021.
//

import Foundation
import CoreData

@objc(ContextMO)
public class ContextMO: NSManagedObject {
	@NSManaged public var key: String
	@NSManaged public var value: String
	@NSManaged public var eventType: String?
}

extension ContextMO {
	static let genericEvent = "__generic_event_type"
	
	static let contextEntity: NSEntityDescription = {
		let entity = NSEntityDescription(from: ContextMO.self)
		
		entity.addProperty(NSAttributeDescription(name: "key", ofType: .stringAttributeType))
		
		entity.addProperty(NSAttributeDescription(name: "value", ofType: .stringAttributeType))
		
		entity.addProperty(NSAttributeDescription(name: "eventType", ofType: .stringAttributeType))
		
		return entity
	}()
}

extension ContextMO {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<ContextMO> {
		return NSFetchRequest<ContextMO>(entityName: NSStringFromClass(self))
	}
	
}

extension ContextMO : Identifiable {}


