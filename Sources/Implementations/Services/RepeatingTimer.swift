//
//  RepeatingTimer.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 01.07.2021.
//

import Foundation

protocol RepeatingTimer {
	typealias TimerBlock = (RepeatingTimer) -> Void
	
	/// Sets new active timer, removing the previous one. Previous timer is cancelled.
	/// - Parameters:
	///   - time: time
	///   - fireBlock: completion, that's called when time comes
	func set(time: TimeInterval, fireBlock: @escaping TimerBlock)

	/// Cancelling timer. CancelBlock gets called
	func cancel()
		
	/// Firing timer. FireBlock gets called
	func fire()
}

/// RepeatingTimer mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52
class RepeatingTimerI: RepeatingTimer {
	
	var fireBlock: RepeatingTimer.TimerBlock?
	var timer: Timer?
	
	private var timerQueue = DispatchQueue(label: "com.jitsu.timer")
		
	func set(time: TimeInterval, fireBlock: @escaping RepeatingTimer.TimerBlock) {
		print("setting new timer")
		if timer != nil {
			self.timer?.invalidate()
			self.timer = nil
		}
		
		self.fireBlock = fireBlock
		
		self.timer = Timer(timeInterval: time, repeats: true) { [weak self] _ in
			guard let self = self else {return}
			self.fireBlock?(self)
		}
		
		timer?.tolerance = 0.2

		RunLoop.main.add(timer!, forMode: .common)
	}
	
	func cancel() {
		self.timer?.invalidate()
		self.timer = nil
	}
	
	func fire() {
		fireBlock?(self)
	}
	
	deinit {
		self.timer?.invalidate()
		self.timer = nil
	}

}
