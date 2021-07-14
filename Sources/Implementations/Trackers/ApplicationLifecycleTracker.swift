//
//  ApplicationLifecycleTracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation
import UIKit

typealias EventBlock = (Event) -> Void

protocol Tracker {
	static func subscribe(_ eventBlock: @escaping EventBlock) -> Tracker
}


class ApplicationLifecycleTracker: Tracker {
	
	// MARK: - Initialization
	
	private var eventBlock: EventBlock
	
	static func subscribe(_ eventBlock: @escaping EventBlock) -> Tracker {
		let tracker = ApplicationLifecycleTracker(eventBlock)
		return tracker
	}
	
	private init(_ eventBlock: @escaping EventBlock) {
		self.eventBlock = eventBlock
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
		UIApplication.significantTimeChangeNotification,
	]

	private func setupTrackers() {
		notifications.forEach { addTracker($0) }
	}
	
	private func addTracker(_ notificationName: NSNotification.Name) {
		addTracker(notificationName) { [weak self] _ in
			guard let self = self else { return }
			let event = JitsuBasicEvent(name: notificationName.rawValue)
			self.eventBlock(event)
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
