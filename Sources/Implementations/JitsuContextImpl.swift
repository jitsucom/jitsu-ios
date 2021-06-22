//
//  JitsuContextImpl.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation


class JitsuContextImpl: JitsuContext {
		
	func addValues(_ values: [String : Any], for eventTypes: [EventType]?, persist: Bool) {
		
	}
	
	func removeValue(for key: String, for eventTypes: [EventType]?) {
		
	}
	
	func clear() {
		
	}
	
	// MARK: - -
	
	init() { // todo: move from init to separate method?
		addValues(deviceInfo, for: nil, persist: false)
		addValues(localeInfo, for: nil, persist: false)
		addValues(sdkVersion, for: nil, persist: false)
	}
	
	// todo: fetch values
	
	private lazy var deviceInfo: [String: [String: String]] = {
		return [
			"parsed_ua":
				[
					"device": "iPhone 12",
					"manufacturer": "Apple",
					"platform": "iOS",
					"os": "iOS",
					"os_version": "14.1",
					"screen_resolution": "1440x900"
				]
		]
	}()
	
	private lazy var localeInfo: [String: String] = {
		return [
			"user_language": "en-GB",
		]
	}()
	
	private lazy var sdkVersion: [String: String] = {
		return ["sdk_version": "1.4.1"]
	}()
	
	func values(for eventType: EventType) -> [String : Any] {
		return [:]
	}
}
