//
//  ManualCoreDataHelpers.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 27.06.2021.
//

import Foundation
import CoreData


extension NSEntityDescription {
	convenience init(from classType: AnyClass) {
		self.init()
		self.name = NSStringFromClass(classType)
		self.managedObjectClassName = NSStringFromClass(classType)
	}
	
	func addProperty(_ property: NSPropertyDescription) {
		self.properties.append(property)
	}
}


extension NSAttributeDescription {
	convenience init(name: String, ofType: NSAttributeType, isOptional: Bool = false) {
		self.init()
		self.name = name
		self.attributeType = ofType
		self.isOptional = isOptional
	}
}
