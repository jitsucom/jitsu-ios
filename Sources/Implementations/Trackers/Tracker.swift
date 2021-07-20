//
//  Tracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation

typealias TrackerEventOutput = (Event) -> Void
typealias TrackerContextOutput = ([String: String]) -> Void

typealias TrackerOutput = (TrackerOutputType) -> Void

enum TrackerOutputType {
	case event(Event)
	case context([String: Any])
}

protocol Tracker { }
