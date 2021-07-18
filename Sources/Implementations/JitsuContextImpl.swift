//
//  JitsuContextImpl.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

struct ContextValue: Hashable {
	var key: JitsuContext.Key
	var value: JSON
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
		return lhs.hashValue == rhs.hashValue
	}
}

class JitsuContextImpl: JitsuContext {
	
	private var specificContext = [EventType : Set<ContextValue>]()
	private var generalContext = Set<ContextValue>()
	
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
		
		try? addValues(localeInfo, for: nil, persist: false)
		try? addValues(appInformation, for: nil, persist: false)

		getDeviceInfo { [weak self] deviceInfo in
			guard let self = self else {return}
			self.deviceInfo = deviceInfo
			try? self.addValues(deviceInfo, for: nil, persist: false)
			completion()
		}
	}
	
	private var contextQueue = DispatchQueue(label: "com.jitsu.contextQueue", attributes: .concurrent)
	
	// MARK: - JitsuContext
	
	func addValues(_ values: [JitsuContext.Key : Any], for eventTypes: [EventType]?, persist: Bool) throws {
		let jsonValues = try values.mapValues { (value) -> JSON in
			return try JSON(value)
		}
		
		addValues(jsonValues, for: eventTypes, persist: persist)
	}
	
	func addValues(_ values: [JitsuContext.Key : JSON], for eventTypes: [EventType]?, persist: Bool) {
		var newValues = [ContextValue]()
		if let eventTypes = eventTypes {
			for eventType in eventTypes {
				newValues = values.map {
					ContextValue(key: $0.key,
								 value: $0.value,
								 eventType: eventType)
				}
			}
		} else {
			newValues = values.map { ContextValue(key: $0.key, value: $0.value, eventType: nil) }
		}
		
		for new in newValues {
			addValue(new, persist: persist)
		}
	}
	
	private func addValue(_ new: ContextValue, persist: Bool) {
		contextQueue.async(flags: .barrier) { [self] in
			if let eventType = new.eventType {
				if specificContext[eventType] != nil {
					specificContext[eventType]?.update(with: new)
				} else {
					specificContext[eventType] = Set([new])
				}
			} else {
				generalContext.update(with: new)
			}
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
			removeSpecificValue(for: key, for: type)
		}
	}
	
	private func removeSpecificValue(for key: JitsuContext.Key, for eventType: EventType) {
		contextQueue.async(flags: .barrier) { [self] in
			guard let eventValues = specificContext[eventType] else { return }
			if let valueToRemove = eventValues.first(where: {$0.key == key}) {
				specificContext[eventType]?.remove(valueToRemove)
				storage.removeContextValue(valueToRemove)
			}
		}
	}
	
	private func removeGenericValue(for key: JitsuContext.Key) {
		contextQueue.async(flags: .barrier) { [self] in
			if let valueToRemove = generalContext.first(where: {$0.key == key}) {
				generalContext.remove(valueToRemove)
				storage.removeContextValue(valueToRemove)
			}
		}
	}
	
	func values(for eventType: EventType?) -> [String: Any] {
		contextQueue.sync {
			let generalValues = generalContext.reduce(into: [:]) { (res, contextValue) in
				res[contextValue.key] = contextValue.value
			}
			
			guard let eventType = eventType,
			   let specificValues = specificContext[eventType] else {
				return generalValues
			}
			
			let eventSpecificValues = specificValues.reduce(into: [:]) { (res, contextValue) in
				res[contextValue.key] = contextValue.value
			}
			
			let mergedValues = eventSpecificValues.merging(generalValues) { (specific, general) -> JSON in
				return specific
			}
			
			return mergedValues
		}
	}
	
	func clear() {
		contextQueue.sync {
			specificContext.removeAll()
			generalContext.removeAll()
		}
		storage.clear()
		setup {}
	}
	
	// MARK: - Automatically generated values
		
	private lazy var appInformation: [String: String] = {
		var info = ["src": "jitsu_ios"]
		info["sdk_version"] = Bundle(for: Self.self).minorVersion
		info["app_build_id"] = Bundle.main.fullVersion
		info["app_name"] = Bundle.main.appName
		return info
	}()
	
	private var deviceInfo: [String: Any]?
	
	func getDeviceInfo(_ completion: @escaping ([String: Any]) -> Void) {
		deviceInfoProvider.getDeviceInfo {(deviceInfo) in
			completion([
				"screen_resolution": deviceInfo.screenResolution, // e.g "1440x900"
				"parsed_ua":
					[
						"device_brand": deviceInfo.manufacturer, // e.g. "Apple"
						"ua_family": deviceInfo.deviceModel, // e.g. "iPhone"
						"device_model": deviceInfo.deviceName, // e.g. "iPhone 12"
						"os_family": deviceInfo.systemName, // e.g. "iOS"
						"os_version": deviceInfo.systemVersion, // e.g. "13.3"
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
