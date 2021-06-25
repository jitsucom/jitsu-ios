//
//  DateService.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 25.06.2021.
//

import Foundation

extension Date {
	
	var utcTime: String {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone(identifier: "UTC")
		return formatter.string(from: self)
	}
	
}
