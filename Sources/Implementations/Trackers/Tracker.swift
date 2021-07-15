//
//  Tracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation

typealias TrackerOutput = (Event) -> Void

protocol Tracker {
	static func subscribe(_ eventBlock: @escaping TrackerOutput) -> Tracker
}
