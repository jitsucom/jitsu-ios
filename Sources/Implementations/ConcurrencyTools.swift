//
//  ConcurrencyTools.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 28.06.2021.
//

import Foundation

// This is a property wrapper that allows safe multithreading
// inspired by: https://www.vadimbulavin.com/swift-atomic-properties-with-property-wrappers/, but with single writer multiple reader


@propertyWrapper
class Atomic<Value> {
	private let queue = DispatchQueue(label: "com.jitsu.atomic", attributes: .concurrent)
	private var _value: Value

	init(wrappedValue: Value) {
		self._value = wrappedValue
	}
	
	var projectedValue: Atomic<Value> {
		return self
	}
	
	func mutate(_ mutation: (inout Value) -> Void) {
		return queue.sync(flags: .barrier) {
			mutation(&self._value)
		}
	}
	
	var wrappedValue: Value {
		get {
			return queue.sync { _value }
		}
		set {
			queue.sync(flags: .barrier) { _value = newValue }
		}
	}
}
