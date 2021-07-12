//
//  LabeledToggle.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 11.07.2021.
//

import Foundation
import UIKit

class LabeledToggle: UIView {
	func setTitle(_ title: String) {
		titleLabel.text = title
	}
	
	var value: Bool {
		return toggle.isOn
	}
	
	func setToggleValue(_ value: Bool) {
		toggle.isOn = value
	}
	
	func setAllowsUserInteraction(_ value: Bool) {
		if value {
			toggle.isEnabled = true
		} else {
			toggle.isEnabled = false
		}
	}
	
	private lazy var titleLabel: UILabel = {
		let v = UILabel()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.textAlignment = .center
		v.font = UIFont.systemFont(ofSize: 12)
		v.isUserInteractionEnabled = false
		return v
	}()
	
	private lazy var toggle: UISwitch = {
		let v = UISwitch()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.isOn = false
		return v
	}()
	
	init() {
		super.init(frame: .zero)
		makeUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		makeUI()
	}
	
	private func makeUI() {
		addSubview(titleLabel)
		addSubview(toggle)
		
		NSLayoutConstraint.activate([
			titleLabel.centerYAnchor.constraint(equalTo: toggle.centerYAnchor, constant: 0),
			titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
		])
		
		NSLayoutConstraint.activate([
			toggle.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
			toggle.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
			toggle.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
			toggle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
		])
	}
}
