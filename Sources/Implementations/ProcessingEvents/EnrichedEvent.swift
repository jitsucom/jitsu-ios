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
	
	var payload: [String: Any]
	
	var context: [String: Any]
	
	var userProperties: [String: Any]
	
	func buildJson() -> [String: Any] {
		var dict: [String: Any] = [
			"event_id": eventId,
			"event_type": name,
			
			"utc_time": utcTime,
			"local_tz_offset": localTimezoneOffset,
		]
		dict.merge(payload) { (val1, val2) in return val1 }
		dict.merge(userProperties) { (val1, val2) in return val1 }
		dict.merge(context) { (val1, val2) in return val1 }
		return dict
	}
}
