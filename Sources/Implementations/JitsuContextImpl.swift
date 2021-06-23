//
//  JitsuContextImpl.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation
//import UIKit // todo: move extracting device info to another class


class JitsuContextImpl: JitsuContext {
		
	func addValues(_ values: [String : Any], for eventTypes: [EventType]?, persist: Bool) {
		
	}
	
	func removeValue(for key: String, for eventTypes: [EventType]?) {
		
	}
	
	func clear() {
		
	}
	
	// MARK: - -
	
	private var deviceInfoProvider: DeviceInfoProvider
	
	init(deviceInfoProvider: DeviceInfoProvider) {
		self.deviceInfoProvider = deviceInfoProvider
		
		addValues(localeInfo, for: nil, persist: false)
		addValues(appInformation, for: nil, persist: false)
		// todo: addValues: accessibility info
		
		getDeviceInfo { [weak self] in
			guard let self = self else {return}
			if let deviceInfo = self.deviceInfo {
				self.addValues(deviceInfo, for: nil, persist: false)
			}
		}
	}
	
	// MARK: - Automatically generated values
		
	private lazy var appInformation: [String: String] = {
		var info = ["src": "jitsu_ios"]
		
		let sdkVersion =  Bundle(for: Self.self).infoDictionary?["CFBundleShortVersionString"] as? String
		info["sdk_version"] = sdkVersion
		
		let mainAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		info["app_version_id"] = sdkVersion // todo: change in spec
		
		let mainAppBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
		info["app_build_id"] = sdkVersion // todo: change in spec
		
		let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
		info["app_name"] = appName
		
		return info
	}()
	
	private var deviceInfo: [String: [String: String]]?
	
	func getDeviceInfo(_ completion: @escaping () -> Void) {
		deviceInfoProvider.getDeviceInfo {[weak self] (deviceInfo) in
			guard let self = self else {return}
			self.deviceInfo = [
				"parsed_ua":
					[
						"device_brand": deviceInfo.manufacturer, // e.g. "Apple"
						"ua_family": deviceInfo.deviceModel, // e.g. "iPhone"
						"device_model": deviceInfo.deviceName, // e.g. "iPhone 12"
						"os_family": deviceInfo.systemName, // e.g. "iOS"
						"os_version": deviceInfo.systemVersion, // e.g. "13.3"
						"screen_resolution": deviceInfo.screenResolution // e.g "1440x900" // todo: here?
					]
			]
		}
	}
	
	private lazy var localeInfo: [String: String] = {
		return [
			"user_language": Bundle.main.preferredLocalizations.first ?? Locale.current.languageCode ?? "unknown",
		]
	}()
	
	func values(for eventType: EventType) -> [String : Any] {
		return [:]
	}
}
