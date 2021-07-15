//
//  AccessibilityTracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 15.07.2021.
//

import Foundation
import UIKit

class AccessibilityTracker: Tracker<[String: String]> {
	
	// MARK: - Initialization
	
	private var trackerOutput: TrackerContextOutput
		
	override init(callback: @escaping ([String: String]) -> Void) {
		self.trackerOutput = callback
		super.init(callback: callback)
		setupTrackers()
	}
	
	// MARK: - Tracking
	
	private lazy var notificationCenter = NotificationCenter.default
	
	private func setupTrackers() {
		let voiceOverObserver = UIAccessibility.voiceOverStatusDidChangeNotification
		addTracker(voiceOverObserver) { [weak self] notification  in
			guard let self = self else {return}
			self.trackerOutput(["voice_over": "true"])
			self.notificationCenter.removeObserver(self, name: voiceOverObserver, object: nil)
		}
	}
	
	private func addTracker(_ notificationName: NSNotification.Name, handler: @escaping (Notification)->()) {
		notificationCenter.addObserver(
			forName: notificationName,
			object: nil,
			queue: nil
		) { notification in
			handler(notification)
		}
	}
}
