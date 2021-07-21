//
//  Jitsu.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 05.07.2021.
//

import Foundation

@objc public final class Jitsu: NSObject {
	
	/// Use `Jitsu.shared` to adress to Jitsu SDK. Make sure to call either `setupClient(with options:)` or `setupMock(_ mockClient:)` before that.
	@objc static public var shared: JitsuClient {
		if let _shared = _shared {
			return _shared
		}
		fatalError("Jitsu: you should initialize Jitsu with setupClient before using it")
	}
	
	@objc static public var userProperties: JitsuUserProperties {
		return Jitsu.shared.userProperties
	}
	
	@objc static public var context: JitsuContext {
		return Jitsu.shared.context
	}
	
	/// Setup Jitsu client with options
	@objc public static func setupClient(with options: JitsuOptions) {
		if (_shared == nil) {
			var serviceLocator: ServiceLocator
			if options.inTestMode {
				serviceLocator = MockServiceLocator()
			} else {
				serviceLocator = ServiceLocatorImpl(options: options)
			}
			
			logLevel = options.logLevel
			_shared = JitsuClientImpl(options: options, deps: serviceLocator)
		}
	}
	
	/// Use this constructor instead of `setupClient` in UnitTests or UITests.
	/// This setup replaces current `shared` value.
	/// - Parameter mockClient: You can either set your own mock, or pass `nil` and rely on ours.
	@objc public static func setupMock(_ mockClient: JitsuClient?) {
		if let mockClient = mockClient {
			_shared = mockClient
		} else {
			_shared = JitsuClientMock()
		}
	}
	
	static private var _shared: JitsuClient?
	
	private override init() {
		super.init()
	}
}
