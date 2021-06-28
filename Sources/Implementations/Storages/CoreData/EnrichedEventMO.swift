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
	
	@NSManaged public var payload: NSDictionary
	
	@NSManaged public var context: NSDictionary

	@NSManaged public var userProperties: NSDictionary
}


extension EnrichedEventMO {
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<EnrichedEventMO> {
		return NSFetchRequest<EnrichedEventMO>(entityName: NSStringFromClass(self))
	}
	
}

extension EnrichedEventMO : Identifiable {
	
}

