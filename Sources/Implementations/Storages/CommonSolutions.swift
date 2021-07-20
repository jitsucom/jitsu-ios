//
//  CommonSolutions.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 21.07.2021.
//

import Foundation


extension Dictionary where Key == String, Value == JSON {
	func encoded() -> NSDictionary {
		return self.mapValues { $0.toString() } as NSDictionary
	}
}

extension NSDictionary {
	func decoded() -> [String: JSON] {
		let dict = self as! [String: String]
		return dict.compactMapValues { JSON.fromString($0) }
	}
}
