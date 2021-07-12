//
//  RandomColor.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 08.07.2021.
//

import Foundation
import UIKit

extension UIColor {
	static var randomColor: UIColor {
		let r: (()->(CGFloat)) = { return CGFloat(Float.random(in: 1...255) / 255) }
		return UIColor(
			red: r(),
			green: r(),
			blue: r(),
			alpha: 1
		)
	}
	
	static var jitsuViolet: UIColor {
		return UIColor(red: 154.0 / 255, green: 52.0 / 255, blue: 246.0 / 255, alpha: 1)
	}
	
	static var jitsuBlue: UIColor {
		return UIColor(red: 77.0 / 255, green: 48.0 / 255, blue: 240.0 / 255, alpha: 1)
	}
	
	static var jitsuBlack: UIColor {
		return UIColor(red: 18.0 / 255, green: 24.0 / 255, blue: 38.0 / 255, alpha: 1)
	}
}

func showError(view: UIView) {
	let backgroundColor = view.backgroundColor
	UIView.animate(withDuration: 0.2) {
		view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
	} completion: { _ in
		UIView.animate(withDuration: 0.3) {
			view.backgroundColor = backgroundColor
		}
	}
}
