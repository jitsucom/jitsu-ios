//
//  UIKitEvents.swift
//  jitsu-ios
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import Foundation
import UIKit

/// Works with UIKit.
@objc public protocol TracksUIKitEvents {
	
	/// Sending the event with screen info
	/// Works like `sendEvent`, but also passes screen info
	/// - Parameters:
	///   - screen: name of the screen
	///   - name: event name
	///   - payload: event params
	@objc func trackScreenEvent(screen: UIViewController, name: EventType, payload: [String : AnyJSONValue])
	
	/// Sending the event with screen info
	/// Works like `sendEvent`, but also passes screen info
	/// - Parameters:
	///   - screen: name of the screen
	///   - event: event
	@objc func trackScreenEvent(screen: UIViewController, event: Event)
	
}

