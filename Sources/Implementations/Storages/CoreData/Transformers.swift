//
//  Transformers.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 30.06.2021.
//

import Foundation

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
		return NSArray.self
	}
	
	override class func allowsReverseTransformation() -> Bool {
		return true
	}
	
	static let name = NSValueTransformerName(rawValue: "ArrayTransformer")
}

@objc final class NSDataTransfomer: NSSecureUnarchiveFromDataTransformer {
	
	override class func transformedValueClass() -> AnyClass {
		return NSData.self
	}
	
	override class func allowsReverseTransformation() -> Bool {
		return true
	}
	
	static let name = NSValueTransformerName(rawValue: "DataTransformer")
}


