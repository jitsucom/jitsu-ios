//
//  JitsuClientImpl+UIKit.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 18.07.2021.
//

import Foundation
import UIKit

/// Works with UIKit.
@objc extension JitsuClientImpl {
	
	@objc func trackScreenEvent(screen: UIViewController, name: EventType, payload: [String : Any]) {
		
		let updatedPayload = payload.merging(screen.screenInfo) { (payload, info) -> Any in
			return payload
		}
		self.trackEvent(name: name, payload: updatedPayload)
	}
	
	@objc func trackScreenEvent(screen: UIViewController, event: Event) {
		let payload = event.payload
		let updatedPayload = payload.merging(screen.screenInfo) { (payload, info) -> Any in
			return payload
		}
		event.payload = updatedPayload
		self.trackEvent(event)
	}
}

fileprivate extension UIViewController {
	var screenInfo: [String: Any] {
		let screenInfo = [
			"screen_title" : "\(self.title ?? "")",
			"screen_class" : "\(type(of: self))"
		]
		return screenInfo
	}
}
