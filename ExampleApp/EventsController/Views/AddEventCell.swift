//
//  AddEventCell.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 08.07.2021.
//

import Foundation
import UIKit

class AddEventCell: UITableViewCell {
	
	// MARK: - Public
	
	var eventCreated: ((String, [String: Any]?) -> Void)?
	var hack: (()-> Void)?
	
	// MARK: - Data
	
	private var eventType: String?
	private var payload: [String: Any]?

	// MARK: - Private
	
	private lazy var nameField: UITextField = {
		let v = UITextField()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.returnKeyType = .done
		v.backgroundColor = .systemBackground
		v.placeholder = "tap to enter name of the event"
		v.delegate = self
		return v
	}()
	
	private lazy var payloadView: UITextView = {
		let v = UITextView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.isScrollEnabled = false
		v.delegate = self
		return v
	}()
	
	private lazy var doneButton: UIButton = {
		let v = UIButton()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.setTitle("done", for: .normal)
		v.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
		return v
	}()
	
	private var tapGesture: UITapGestureRecognizer = {
		let v =  UITapGestureRecognizer(target: self, action: #selector(cellTapped))
		v.numberOfTapsRequired = 1
		return v
	}()
	
	// MARK: - Setup
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		makeUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		makeUI()
	}
	
	private func makeUI() {
		contentView.addSubview(nameField)
		contentView.addSubview(doneButton)
		contentView.addSubview(payloadView)
		
		addGestureRecognizer(tapGesture)
		backgroundColor = .randomColor
		showPlaceholder()

		updateConstraints()
	}
	
	// MARK: - Constraints
	
	override class var requiresConstraintBasedLayout: Bool {
		return true
	}
		
	private var payloadViewHeight: NSLayoutConstraint?
	
	override func updateConstraints() {
		NSLayoutConstraint.activate([
			nameField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			nameField.heightAnchor.constraint(equalToConstant: 40),
			nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
		])
		
		NSLayoutConstraint.activate([
			payloadView.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 8),
			payloadView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
			payloadView.leadingAnchor.constraint(equalTo: nameField.leadingAnchor, constant: 0),
			payloadView.widthAnchor.constraint(equalTo: nameField.widthAnchor, multiplier: 3/4),
			payloadView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
		])
		
		NSLayoutConstraint.activate([
			doneButton.topAnchor.constraint(equalTo: payloadView.topAnchor, constant: 8),
			doneButton.heightAnchor.constraint(equalToConstant: 16),
			doneButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor, constant: -16),
		])
			
		super.updateConstraints()
	}
	
	// MARK: - Actions
	
	@objc func cellTapped() {
		self.nameField.becomeFirstResponder()
		self.nameField.inputAccessoryView = self
	}
	
	@objc func doneButtonPressed() {
		eventType = nameField.text
		if let eventType = eventType, eventType.count > 0 {
			eventCreated?(eventType, payload)
			clear()
		}
	}
	
	func clear() {
		self.nameField.text = ""
		self.payloadView.text = ""
		self.payloadView.endEditing(true)
		showPlaceholder()
		hack?()
		backgroundColor = .randomColor
	}
	
	override func becomeFirstResponder() -> Bool {
		self.nameField.becomeFirstResponder()
		return false
	}
	
	override func resignFirstResponder() -> Bool {
		self.nameField.resignFirstResponder()
	}
}

extension AddEventCell: UITextFieldDelegate {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if let text = nameField.text, text.count > 0 {
			eventType = text
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		nameField.endEditing(true)
		return false
	}
}

extension AddEventCell: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text.starts(with: "tap to") {
			hidePlaceholder()
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		hack?()
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if let text = textView.text, text.count > 0 {
		} else {
			payload = nil
			showPlaceholder()
		}
	}
	
	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		guard let text = textView.text, text.count > 0 else {
			textView.endEditing(true)
			return true
		}
				
		if let data = text.data(using: .utf8) {
			let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
			if let json = json {
				self.payload = json
				return true
			}
		}
		
		textView.backgroundColor = .systemRed
		UIView.animate(withDuration: 0.2) {
			textView.backgroundColor = .systemBackground
		}
		
		return false
	}
	
	func showPlaceholder() {
		payloadView.text = "tap to enter payload as JSON"
		payloadView.textColor = .placeholderText
	}
	
	func hidePlaceholder() {
		payloadView.text = ""
		payloadView.textColor = .darkText
	}
}
