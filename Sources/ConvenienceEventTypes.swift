//
//  ConvenienceMethods.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 21.07.2021.
//

import Foundation
import CoreLocation

@objc public class JitsuBasicEvent: NSObject, Event {
	
	public var name: EventType
	
	public var payload = [String : Any]()
	
	@objc public init(name: EventType, payload: [String: Any] = [:]) {
		self.name = name
		self.payload = payload
	}
}

@objc public class LocationEvent: NSObject, Event {
	public var name: EventType
	
	public var payload: [String : AnyJSONValue]
	
	@objc public convenience init(location: CLLocation) {
		self.init(name: "location update", location: location)
	}
	
	@objc public convenience init(name: String, location: CLLocation) {
		self.init(name:name, location: location, payload: [:])
	}
	
	@objc public init(name: String, location: CLLocation, payload: [String: AnyJSONValue]) {
		self.name = name
		
		let locationDict = [
			"location" : [
				"latitude": "\(location.coordinate.latitude)",
				"longitude": "\(location.coordinate.longitude)",
				"accuracy": "\(location.horizontalAccuracy)",
			]
		]
		
		self.payload = payload.merging(locationDict) { payloadValue, locationValue in return locationValue }
	}
}
