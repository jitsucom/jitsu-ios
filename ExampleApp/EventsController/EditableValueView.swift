//
//  EditableValueView.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 11.07.2021.
//

import Foundation
import UIKit

class EditableValueView: UIView, UITextFieldDelegate {
	
	func setTitle(_ title: String) {
		titleLabel.text = title
	}
	
	func setTextValue(_ title: String) {
		valueField.text = title
	}
	
	func setButtonTitle(_ title: String) {
		button.setTitle(title, for: .normal)
	}
		
	func setAction(_ action: @escaping (String) -> Void) {
		self.action = action
	}
	
	private var action: ((String) -> Void )?
	
	private lazy var titleLabel: UILabel = {
		let v = UILabel()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.textAlignment = .center
		v.font = UIFont.systemFont(ofSize: 12)
		v.isUserInteractionEnabled = false
		return v
	}()
	
	private lazy var valueField: UITextField = {
		let v = UITextField()
		v.isUserInteractionEnabled = false
		v.translatesAutoresizingMaskIntoConstraints = false
		v.font = UIFont.systemFont(ofSize: 12)
		v.textAlignment = .center
		v.isUserInteractionEnabled = false
		v.delegate = self
		return v
	}()
	
	private lazy var button: UIButton = {
		let v = UIButton(type: .custom)
		v.translatesAutoresizingMaskIntoConstraints = false
		v.setTitleColor(UIColor.secondaryLabel, for: .normal)
		v.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
		v.titleLabel?.font = UIFont.systemFont(ofSize: 10)
		v.isUserInteractionEnabled = false
		return v
	}()
	
	private lazy var tapGesture: UITapGestureRecognizer = {
		let v = UITapGestureRecognizer(target: self, action: #selector(buttonPressed))
		v.numberOfTapsRequired = 1
		return v
	}()
	
	@objc func buttonPressed() {
		if valueField.isUserInteractionEnabled {
			valueField.endEditing(true)
			if let text = valueField.text {
				action?(text)
			}
			valueField.isUserInteractionEnabled = false
			valueField.resignFirstResponder()
		} else {
			valueField.isUserInteractionEnabled = true
			valueField.becomeFirstResponder()
		}
	}
	
	init() {
		super.init(frame: .zero)
		makeUI()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		makeUI()
	}
	
	private func makeUI() {
		layer.borderWidth = 1
		layer.borderColor = UIColor.secondarySystemFill.cgColor
		backgroundColor = UIColor.secondarySystemFill.withAlphaComponent(0.2)
		layer.cornerRadius = 4

		addSubview(titleLabel)
		addSubview(valueField)
		addSubview(button)
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
			titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
			titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
		])
		
		NSLayoutConstraint.activate([
			valueField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
			valueField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
			valueField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
		])
		
		NSLayoutConstraint.activate([
			button.topAnchor.constraint(equalTo: valueField.bottomAnchor, constant: -8),
			button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
			button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
			button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
		])
		
		addGestureRecognizer(tapGesture)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		buttonPressed()
		return true
	}
}
