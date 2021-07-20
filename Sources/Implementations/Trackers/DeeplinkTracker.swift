//
//  DeeplinkTracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation
import UIKit

class DeeplinkTracker: Tracker {
	
	// MARK: - Initialization
	
	private var trackerOutput: TrackerOutput
	
	init(callback: @escaping TrackerOutput) {
		self.trackerOutput = callback
		setupTrackers()
	}
	
	// MARK: - Tracking
	
	private lazy var notificationCenter = NotificationCenter.default
	
	private func setupTrackers() {
		addTracker(UIApplication.didFinishLaunchingNotification) { [weak self] notification  in
			guard let self = self else {return}
			guard let userInfo = notification.userInfo else { return }
			if let url = userInfo[UIApplication.LaunchOptionsKey.url] {
				let event = JitsuBasicEvent(
					name: "Deeplink Opened",
					payload: [
						"url": url
					])
				self.trackerOutput(.event(event))
			}
		}
		if #available(iOS 13.0, *) {
			addTracker(UIScene.willConnectNotification) { (notification) in
				// one day Apple will be passing deeplink info there
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
