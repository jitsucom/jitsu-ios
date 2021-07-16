//
//  Logger.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 16.07.2021.
//

// MARK: - Private

fileprivate typealias Log = (JitsuLogLevel, String) -> Void

fileprivate var logger: Log {
	return makeLogger(logLevel)
}

fileprivate extension JitsuLogLevel {
	var name: String {
		switch self {
		case .debug:
			return "DEBUG"
		case .info:
			return "INFO"
		case .warning:
			return "WARNING"
		case .error:
			return "ERROR"
		case .critical:
			return "CRITICAL"
		case .none:
			return "NONE"
		}
	}
}

fileprivate func makeLogger(_ minimalLogLevel: JitsuLogLevel) -> Log {
	func log1(_ logLevel: JitsuLogLevel, message: String) {
		if logLevel.rawValue >= minimalLogLevel.rawValue {
			print("\(logLevel.name): \(message)")
		}
	}
	return log1
}

// MARK: - Public

var logLevel: JitsuLogLevel = .none

func logDebug(_ message: String) {
	logger(.debug, message)
}

func logInfo(_ message: String) {
	logger(.info, message)
}

func logWarning(_ message: String) {
	logger(.warning, message)
}

func logError(_ message: String) {
	logger(.error, message)
}

func logCritical(_ message: String) {
	logger(.critical, message)
}

// MARK: - Sugar

func logInfo<T: Any>(from cls: T, _ message: String) {
	logger(.info, "\(type(of: cls)): \(message)")
}

func logDebugFrom<T: Any>(_ cls: T, _ message: String) {
	logger(.debug, "\(type(of: cls)): \(message)")
}

func logError<T: Any>(from cls: T, _ message: String) {
	logger(.error, "\(type(of: cls)): \(message)")
}

func logCriticalFrom<T: Any>(_ cls: T, _ message: String) {
	logger(.critical, "\(type(of: cls)): \(message)")
}
