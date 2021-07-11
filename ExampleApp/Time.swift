//
//  Time.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 10.07.2021.
//

import Foundation

extension Date {
	var timeString: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.timeStyle = .medium
		return formatter.string(from: self)
	}
}
