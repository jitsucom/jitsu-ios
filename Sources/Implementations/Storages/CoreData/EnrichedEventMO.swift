//
//  EnrichedEventMo.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 27.06.2021.
//

import Foundation
import CoreData


@objc(EnrichedEventMO)
public class EnrichedEventMO: NSManagedObject {
	
	@NSManaged public var eventId: String
	
	@NSManaged public var name: String
	
	@NSManaged public var utcTime: String
	@NSManaged public var timezone: Int
	
	@NSManaged public var payload: NSDictionary
	
	@NSManaged public var context: NSDictionary

	@NSManaged public var userProperties: NSDictionary
}


extension EnrichedEventMO {
	static let eventEntity: NSEntityDescription = {
		let eventEntity = NSEntityDescription(from: EnrichedEventMO.self)
		
		eventEntity.addProperty(NSAttributeDescription(name: "eventId", ofType: .stringAttributeType))
		eventEntity.addProperty(NSAttributeDescription(name: "name", ofType: .stringAttributeType))
		
		eventEntity.addProperty(NSAttributeDescription(name: "utcTime", ofType: .stringAttributeType))
		eventEntity.addProperty(NSAttributeDescription(name: "timezone", ofType: .integer64AttributeType))
		
		eventEntity.addProperty(NSAttributeDescription(name: "payload", ofType: .transformableAttributeType, valueTransformerName: DictTransformer.name))
		
		eventEntity.addProperty(NSAttributeDescription(name: "context", ofType: .transformableAttributeType, valueTransformerName: DictTransformer.name))
		eventEntity.addProperty(NSAttributeDescription(name: "userProperties", ofType: .transformableAttributeType, valueTransformerName: DictTransformer.name))
		
		return eventEntity
	}()
}

extension EnrichedEventMO {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<EnrichedEventMO> {
		return NSFetchRequest<EnrichedEventMO>(entityName: NSStringFromClass(self))
	}
	
}

extension EnrichedEventMO : Identifiable {}

