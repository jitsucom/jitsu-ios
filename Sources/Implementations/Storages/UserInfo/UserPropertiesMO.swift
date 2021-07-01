//
//  UserPropertiesMO.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 01.07.2021.
//

import Foundation
import CoreData

@objc(UserPropertiesMO)
public class UserPropertiesMO: NSManagedObject {
	@NSManaged public var anonymousUserId: String
	@NSManaged public var userIdentifier: String?
	@NSManaged public var email: String?
	@NSManaged public var otherIdentifiers: NSDictionary
}

extension UserPropertiesMO {
	static let userPropertiesEntity: NSEntityDescription = {
		let entity = NSEntityDescription(from: UserPropertiesMO.self)
		
		entity.addProperty(NSAttributeDescription(name: "anonymousUserId", ofType: .stringAttributeType))
		entity.addProperty(NSAttributeDescription(name: "userIdentifier", ofType: .stringAttributeType, isOptional: true))
		entity.addProperty(NSAttributeDescription(name: "email", ofType: .stringAttributeType, isOptional: true))
		entity.addProperty(NSAttributeDescription(name: "otherIdentifiers", ofType: .transformableAttributeType, valueTransformerName: DictTransformer.name))
		
		return entity
	}()
}

extension UserPropertiesMO {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<UserPropertiesMO> {
		return NSFetchRequest<UserPropertiesMO>(entityName: NSStringFromClass(self))
	}
}

extension UserPropertiesMO : Identifiable {}
