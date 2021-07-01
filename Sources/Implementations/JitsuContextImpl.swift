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
	
	@Atomic private var specificContext = [EventType : Set<ContextValue>]()
	@Atomic private var generalContext = Set<ContextValue>()
	
	private var storage: ContextStorage
	private var deviceInfoProvider: DeviceInfoProvider

	init(storage: ContextStorage, deviceInfoProvider: DeviceInfoProvider) {
		self.storage = storage
		self.deviceInfoProvider = deviceInfoProvider
	}
	
	func setup(_ completion: @escaping () -> Void) {
		let contextValues =  storage.loadContext()
		for value in contextValues {
			addValue(value, persist: false)
		}
		
		addValues(localeInfo, for: nil, persist: false)
		addValues(appInformation, for: nil, persist: false)
		// todo: addValues: accessibility info

		getDeviceInfo { [weak self] deviceInfo in
			guard let self = self else {return}
			self.deviceInfo = deviceInfo
			self.addValues(deviceInfo, for: nil, persist: false)
			completion()
		}
	}
	
	// MARK: - JitsuContext
	
	func addValues(_ values: [JitsuContext.Key : Any], for eventTypes: [EventType]?, persist: Bool) {
		var newValues = [ContextValue]()
		if let eventTypes = eventTypes {
			for eventType in eventTypes {
				newValues = values.map { ContextValue(key: $0.key, value: $0.value, eventType: eventType) }
			}
		} else {
			newValues = values.map { ContextValue(key: $0.key, value: $0.value, eventType: nil) }
		}
		
		for new in newValues {
			addValue(new, persist: persist)
		}
	}
	
	private func addValue(_ new: ContextValue, persist: Bool) {
		if let eventType = new.eventType {
			if $specificContext.value[eventType] != nil {
				$specificContext.mutate {$0[eventType]?.update(with: new)}
			} else {
				$specificContext.mutate {$0[eventType] = Set([new])}
			}
		} else {
			$generalContext.mutate {$0.update(with: new)}
		}
		
		if persist {
			storage.saveContextValue(new)
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
		guard let eventValues = $specificContext.value[eventType] else { return }
		if let valueToRemove = eventValues.first(where: {$0.key == key}) {
			$specificContext.mutate { state in
				state[eventType]?.remove(valueToRemove)
			}
			storage.removeContextValue(valueToRemove)
		}
	}
	
	private func removeGenericValue(for key: JitsuContext.Key) {
		if let valueToRemove = $generalContext.value.first(where: {$0.key == key}) {
			$generalContext.mutate { state in
				state.remove(valueToRemove)
			}
			storage.removeContextValue(valueToRemove)
		}
	}
		
	func values(for eventType: EventType?) -> [String: Any] {
		var values = Set<ContextValue>()
		values.formUnion($generalContext.value)
		if let eventType = eventType {
			let eventSpecificValues = $specificContext.value[eventType] ?? Set()
			eventSpecificValues.forEach { values.update(with: $0) }
		}
		
		return values.reduce(into: [:]) { (res, contextValue) in
			res[contextValue.key] = contextValue.value
		}
	}
	
	func clear() {
		$specificContext.mutate { $0.removeAll() }
		$generalContext.mutate { $0.removeAll() }
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
