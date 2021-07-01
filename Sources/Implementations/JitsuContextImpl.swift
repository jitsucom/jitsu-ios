//
//  JitsuContextImpl.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

struct ContextValue: Hashable {
	
	var key: JitsuContext.Key
	var value: Any
	var eventType: EventType?
	
	func hash(into hasher: inout Hasher) {
		guard let eventType = eventType else {
			"\(key) : general".hash(into: &hasher)
			return
		}
		let description = "\(key): \(eventType)"
		description.hash(into: &hasher)
	}
	
	static func == (lhs: ContextValue, rhs: ContextValue) -> Bool {
		// we use this equality so values are always updated
		return lhs.key == rhs.key
	}
}

class JitsuContextImpl: JitsuContext {
	
	@Atomic private var specificContextValues = [EventType : Set<ContextValue>]()
	@Atomic private var generalContextValues = Set<ContextValue>()
	
	private var storage: ContextStorage
	private var deviceInfoProvider: DeviceInfoProvider

	init(storage: ContextStorage, deviceInfoProvider: DeviceInfoProvider) {
		self.storage = storage
		self.deviceInfoProvider = deviceInfoProvider
	}
	
	func setup(_ completion: @escaping () -> Void) {
		storage.loadContext { [weak self] contextValues in
			guard let self = self else {return}
			for value in contextValues {
				if let eventType = value.eventType {
					if self.specificContextValues[eventType] != nil {
						self.specificContextValues[eventType]?.update(with: value)
					} else {
						self.specificContextValues[eventType] = Set([value])
					}
				} else {
					self.generalContextValues.update(with: value)
				}
			}
		}
		
//		addValues(localeInfo, for: nil, persist: false)
//		addValues(appInformation, for: nil, persist: false)
//		// todo: addValues: accessibility info
//
//		getDeviceInfo { [weak self] deviceInfo in
//			guard let self = self else {return}
//			self.deviceInfo = deviceInfo
//			self.addValues(deviceInfo, for: nil, persist: false)
//			completion()
//		}
	}
	
	// MARK: - JitsuContext
	
	func addValues(_ values: [JitsuContext.Key : Any], for eventTypes: [EventType]?, persist: Bool) {
		if let eventTypes = eventTypes {
			for eventType in eventTypes {
				addEventSpecificValues(values, for: eventType, persist: persist)
			}
		} else {
			addGenericValues(values, persist: persist)
		}
	}
	
	private func addGenericValues(_ values: [JitsuContext.Key : Any], persist: Bool) {
		for (key, value) in values {
			let new = ContextValue(key: key, value: value, eventType: nil)
			generalContextValues.update(with: new)
			if persist {
				storage.saveContextValue(new)
			}
		}
	}
	
	private func addEventSpecificValues(_ values: [JitsuContext.Key : Any], for eventType: EventType, persist: Bool) {
		for (key, value) in values {
			let new = ContextValue(key: key, value: value, eventType: eventType)
			if (specificContextValues[eventType] != nil) {
				specificContextValues[eventType]?.update(with: new)
			} else {
				specificContextValues[eventType] = Set([new])
			}
			if persist {
				storage.saveContextValue(new)
			}
		}
	}
	
	func removeValue(for key: JitsuContext.Key, for eventTypes: [EventType]?) {
		guard let eventTypes = eventTypes else {
			removeGenericValue(for: key)
			return
		}
		
		for type in eventTypes {
			removeValue(for: key, for: type)
		}
	}
	
	private func removeValue(for key: JitsuContext.Key, for eventType: EventType) {
		guard let eventValues = specificContextValues[eventType] else { return }
		if let valueToRemove = eventValues.first(where: {$0.key == key}) {
			specificContextValues[eventType]?.remove(valueToRemove)
			storage.removeContextValue(valueToRemove)
		}
	}
	
	private func removeGenericValue(for key: JitsuContext.Key) {
		if let valueToRemove = generalContextValues.first(where: {$0.key == key}) {
			generalContextValues.remove(valueToRemove)
			storage.removeContextValue(valueToRemove)
		}
	}
		
	func values(for eventType: EventType?) -> [String: Any] {
		var values = Set<ContextValue>()
		values.formUnion(generalContextValues)
		if let eventType = eventType {
			let eventSpecificValues = specificContextValues[eventType] ?? Set()
			eventSpecificValues.forEach { values.update(with: $0) }
		}
		
		return values.reduce(into: [:]) { (res, contextValue) in
			res[contextValue.key] = contextValue.value
		}
	}
	
	func clear() {
		specificContextValues.removeAll()
		generalContextValues.removeAll()
		storage.clear()
		setup {}
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
	
	private var deviceInfo: [String: Any]?
	
	func getDeviceInfo(_ completion: @escaping ([String: Any]) -> Void) {
		deviceInfoProvider.getDeviceInfo {(deviceInfo) in
			completion([
				"parsed_ua":
					[
						"device_brand": deviceInfo.manufacturer, // e.g. "Apple"
						"ua_family": deviceInfo.deviceModel, // e.g. "iPhone"
						"device_model": deviceInfo.deviceName, // e.g. "iPhone 12"
						"os_family": deviceInfo.systemName, // e.g. "iOS"
						"os_version": deviceInfo.systemVersion, // e.g. "13.3"
						"screen_resolution": deviceInfo.screenResolution // e.g "1440x900" // todo: here?
					]
			])
		}
	}
	
	private lazy var localeInfo: [String: String] = {
		return [
			"user_language": Bundle.main.preferredLocalizations.first ?? Locale.current.languageCode ?? "unknown",
		]
	}()
}
