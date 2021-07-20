//
//  JitsuConfiguration.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 20.07.2021.
//

import Foundation
import Jitsu

private let jitsuApiKey = "api_key"

func saveApiKey(_ key: String) {
	UserDefaults.standard.setValue(key, forKey: jitsuApiKey)
}

@discardableResult
func signInJitsu() -> Bool {
	let apiKey = UserDefaults.standard.value(forKey: jitsuApiKey) as? String
	
	if let apiKey = apiKey {
		let options = JitsuOptions(
			apiKey: apiKey,
			trackingHost: "https://t.jitsu.com/api/v1/event",
			logLevel: JitsuLogLevel.info
		)
		options.locationTrackingOptions = [.trackLocation, .addLocationOnAppLaunch, .trackPermissionChanges]
		Jitsu.setupClient(with: options)
		return true
	}
	return false
}

func signOutJitsu() {
	UserDefaults.standard.setValue(nil, forKey: jitsuApiKey)
}
