//
//  ConvenienceMethods.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 21.07.2021.
//

import Foundation
import CoreLocation

@objcMembers public class LocationEvent: Event {
	public var name: EventType
	
	public var payload: [String : Any]
	
	public convenience init(location: CLLocation) {
		self.init(name: "location update", location: location)
	}
	
	public convenience init(name: String, location: CLLocation) {
		self.init(name:name, location: location, payload: [:])
	}
	
	public init(name: String, location: CLLocation, payload: [String: Any]) {
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
