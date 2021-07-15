//
//  ApplicationLifecycleTracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation
import UIKit

class ApplicationLifecycleTracker: Tracker<Event> {
	
	// MARK: - Initialization
	
	private var trackerOutput: TrackerEventOutput
	
	override init(callback: @escaping (Event) -> Void) {
		self.trackerOutput = callback
		super.init(callback: callback)
		setupTrackers()
	}

	// MARK: - Tracking

	private lazy var notificationCenter = NotificationCenter.default
	
	private var notifications = [
		// more info about lifecycle events:
		// https://developer.apple.com/documentation/uikit/app_and_environment/managing_your_app_s_life_cycle

		UIApplication.didFinishLaunchingNotification,
		UIApplication.willEnterForegroundNotification,
		UIApplication.didBecomeActiveNotification,

		UIApplication.didEnterBackgroundNotification,
		UIApplication.willResignActiveNotification,
		UIApplication.willTerminateNotification,
		
		UIApplication.backgroundRefreshStatusDidChangeNotification,
		
		UIApplication.didReceiveMemoryWarningNotification,
	]

	private func setupTrackers() {
		notifications.forEach { addTracker($0) }
	}
	
	private func addTracker(_ notificationName: NSNotification.Name) {
		addTracker(notificationName) { [weak self] _ in
			guard let self = self else { return }
			let event = JitsuBasicEvent(name: notificationName.rawValue)
			self.trackerOutput(event)
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
