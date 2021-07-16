//
//  UpdateTracker.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation

class UpdateTracker: Tracker<Event> {
	
	// MARK: - Initialization
	
	private var trackerOutput: TrackerEventOutput
	
	override init(callback: @escaping (Event) -> Void) {
		self.trackerOutput = callback
		super.init(callback: callback)
		setupTrackers()
	}
	
	// MARK: - Tracking
	
	private var appVersionKey = "appVersionKey"

	private func setupTrackers() {
		let appVersion = Bundle.main.minorVersion
		
		let previousVersion = UserDefaults.standard.value(forKey: appVersionKey) as? String
		
		switch previousVersion {
		case .none:
			sendAppInstalled(version: appVersion)
		case appVersion:
			return
		case .some(let previous):
			sendAppUpdated(from: previous, to: appVersion)
		}
					
		UserDefaults.standard.setValue(appVersion, forKey: appVersionKey)
	}
	
	private func sendAppInstalled(version: String?) {
		let event = JitsuBasicEvent(
			name: "App Installed",
			payload: ["version": version ?? ""]
		)
		trackerOutput(event)
	}
	
	private func sendAppUpdated(from fromVersion: String?, to toVersion: String?) {
		let event = JitsuBasicEvent(
			name: "App Updated",
			payload: ["from_version" : fromVersion ?? "",
					  "to_version": toVersion ?? ""]
		)
		trackerOutput(event)
	}
	

	
	private func addTracker(_ notificationName: NSNotification.Name, handler: @escaping (Notification)->()) {
//		notificationCenter.addObserver(
//			forName: notificationName,
//			object: nil,
//			queue: nil
//		) { notification in
//			handler(notification)
//		}
	}
}