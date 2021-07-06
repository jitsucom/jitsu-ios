//
//  EnrichedEvent.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 01.07.2021.
//

import Foundation

struct EnrichedEvent {
	typealias EventId = String
	
	var eventId: EventId
	
	var name: String
	
	var utcTime: String
	var localTimezoneOffset: Int
	
	var payload: [String: JSON]
	
	var context: [String: JSON]
	
	var userProperties: [String: JSON]
	
	func buildJson() -> [String: JSON] {
		var dict: [String: JSON] = [
			"event_id": eventId.jsonValue,
			"event_type": name.jsonValue,
			
			"utc_time": utcTime.jsonValue,
			"local_tz_offset": localTimezoneOffset.jsonValue,
		]
		dict.merge(payload) { (val1, val2) in return val1 }
		dict.merge(userProperties) { (val1, val2) in return val1 }
		dict.merge(context) { (val1, val2) in return val1 }
		return dict
	}
}
