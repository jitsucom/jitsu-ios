//
//  SignOut.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 12.07.2021.
//

import Foundation
import UIKit
import Jitsu

extension UIViewController {
	open override var canBecomeFirstResponder: Bool {
		return true
	}
	
	open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: { _ in
			signOutJitsu()
			let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
			let authVC = storyboard.instantiateViewController(withIdentifier: "auth")
			authVC.modalPresentationStyle = .fullScreen
			self.show(authVC, sender: self)
		}))
		alert.addAction(UIAlertAction(title: "Turn off", style: .default, handler: { _ in
			Jitsu.shared.turnOff()
		}))
		
		alert.addAction(UIAlertAction(title: "Turn on", style: .default, handler: { _ in
			Jitsu.shared.turnOn()
		}))
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		show(alert, sender: self)
	}
}
