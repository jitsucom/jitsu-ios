//
//  Jitsu.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 05.07.2021.
//

import Foundation

@objc public final class Jitsu: NSObject {
	
	@objc static public var shared: JitsuClient {
		if let _shared = _shared {
			return _shared
		}
		fatalError("Jitsu: you should initialize Jitsu with setupClient before using it")
	}
	
	@objc public static func setupClient(with options: JitsuOptions) {
		if (_shared == nil) {
			let serviceLocator = ServiceLocatorImpl(options: options)
			logLevel = options.logLevel
			_shared = JitsuClientImpl(options: options, deps: serviceLocator)
		}
	}
	
	static private var _shared: JitsuClient?
	
	private override init() {
		super.init()
	}
}
