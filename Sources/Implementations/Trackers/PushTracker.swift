//
//  PushTracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation
import UIKit

class PushTracker: Tracker {
	
	// MARK: - Initialization
	
	private var trackerOutput: TrackerOutput
	
	static func subscribe(_ eventBlock: @escaping TrackerOutput) -> Tracker {
		let tracker = PushTracker(eventBlock)
		return tracker
	}
	
	private init(_ eventBlock: @escaping TrackerOutput) {
		self.trackerOutput = eventBlock
		setupTrackers()
	}
	
	// MARK: - Tracking
	
	private lazy var notificationCenter = NotificationCenter.default
	
	private func setupTrackers() {
		addTracker(UIApplication.didFinishLaunchingNotification) { [weak self] notification  in
			guard let self = self else {return}
			guard let userInfo = notification.userInfo else { return }
			if userInfo[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
				self.trackerOutput(JitsuBasicEvent(name: "Remote Notification Opened"))
			}
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
