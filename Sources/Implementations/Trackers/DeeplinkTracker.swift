//
//  DeeplinkTracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

// exampleApp://
// track, pass `url` in payload
// userInfo.lauchOptions
import Foundation
import UIKit

class DeeplinkTracker: Tracker {
	
	// MARK: - Initialization
	
	private var trackerOutput: TrackerOutput
	
	static func subscribe(_ eventBlock: @escaping TrackerOutput) -> Tracker {
		let tracker = DeeplinkTracker(eventBlock)
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
			if let url = userInfo[UIApplication.LaunchOptionsKey.url] {
				let event = JitsuBasicEvent(
					name: "Deeplink Opened",
					payload: [
						"url": url
					])
				self.trackerOutput(event)
			}
		}
		if #available(iOS 13.0, *) {
			addTracker(UIScene.willConnectNotification) { (notification) in
				
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
