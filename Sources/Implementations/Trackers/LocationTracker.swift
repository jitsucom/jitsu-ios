//
//  LocationTracker.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 18.07.2021.
//

import Foundation
import CoreLocation

class LocationTracker: NSObject, Tracker, CLLocationManagerDelegate {
	
	// MARK: - Initialization
	
	private var trackerOutput: TrackerOutput
	private var options: [JitsuOptions.LocationTrackingOptions]
	
	init(options: [JitsuOptions.LocationTrackingOptions], trackerOutput: @escaping TrackerOutput) {
		self.trackerOutput = trackerOutput
		self.options = options
		super.init()
		
		setupTracker()
	}
	
	// MARK: - Tracking
	
	private lazy var locationManager = CLLocationManager()
	
	private func setupTracker() {
		locationManager.delegate = self
		trackAppLaunchLocation()
	}
	
	private var appLaunchLocationTracked = false
	private func trackAppLaunchLocation() {
		requestLocationIfPossible()
	}
	
	// MARK: - Permission
	
	private var authStatus: CLAuthorizationStatus {
		if #available(iOS 14.0, *) {
			return locationManager.authorizationStatus
		} else {
			return CLLocationManager.authorizationStatus()
		}
	}
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if options.contains(.trackPermissionChanges) {
			trackerOutput(.context(
				["location_auth_status": "\(authStatus.stringValue)"]
			))
			trackerOutput(.event(
				JitsuBasicEvent(name: "location permission change", payload: ["location_auth_status": "\(authStatus.stringValue)"])
			))
		}
		
		if options.contains(.addLocationOnAppLaunch) && !appLaunchLocationTracked {
			requestLocationIfPossible()
		}
	}
	
	// MARK: - Updating location
	
	private func requestLocationIfPossible() {
		switch authStatus {
		case .notDetermined:
			break
		case .restricted:
			break
		case .denied:
			break
		case .authorizedAlways:
			logInfo(from: self, "JITSU requesting 🗺")
			locationManager.requestLocation()
			break
		case .authorizedWhenInUse:
			logInfo(from: self, "JITSU requesting 🗺")
			locationManager.requestLocation()
			break
		@unknown default:
			break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		logInfo(from: self, "JITSU got locations 🗺")
		guard let location = locations.first else { return }
		let payload = [
			"location" : [
				"latitude": "\(location.coordinate.latitude)",
				"longitude": "\(location.coordinate.longitude)",
				"accuracy": "\(location.horizontalAccuracy)",
			]
		]
		
		if options.contains(.addLocationOnAppLaunch) && !appLaunchLocationTracked {
			trackerOutput(.context(payload))
			appLaunchLocationTracked = true
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		logError("\(#function), \(error)")
	}
	
}

fileprivate extension CLAuthorizationStatus {
	var stringValue: String {
		switch self {
		case .notDetermined:
			return "notDetermined"
		case .restricted:
			return "restricted"
		case .denied:
			return "denied"
		case .authorizedAlways:
			return "authorizedAlways"
		case .authorizedWhenInUse:
			return "authorizedWhenInUse"
		@unknown default:
			return "default (value unknown)"
		}
	}
}
