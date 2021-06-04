//
//  UIKitEvents.swift
//  jitsu-ios
//
//  Created by Leonid Serebryanyy on 04.06.2021.
//

import Foundation
import UIKit


/// Works with UIKit.
public protocol SendsUIKitEvents {
	
	/// Sending the event with screen info
	/// Works like `sendEvent`, but also passes screen info
	/// - Parameters:
	///   - screen: name of the screen
	///   - name: event name
	///   - params: event params
	func sendScreenEvent(screen: UIViewController, name: EventName, params: [String : Any])
	
	/// Sending the event with screen info
	/// Works like `sendEvent`, but also passes screen info
	/// - Parameters:
	///   - screen: name of the screen
	///   - event: event
	func sendScreenEvent(screen: UIViewController, event: Event)
	
}

