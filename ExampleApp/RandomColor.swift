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
}
