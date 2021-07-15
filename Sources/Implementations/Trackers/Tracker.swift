//
//  Tracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation

typealias TrackerEventOutput = (Event) -> Void
typealias TrackerContextOutput = ([String: String]) -> Void

class Tracker<T> {
	init(callback: @escaping (T) -> Void) {}
}
