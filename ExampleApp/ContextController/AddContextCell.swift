//
//  AddContextValueCell.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 09.07.2021.
//

import Foundation
import UIKit

class AddContextCell: UITableViewCell {
	
	// MARK: - Public
	
	var valueCreated: ((ContextValue) -> Void)?
	var hack: (()-> Void)?
	
	// MARK: - Private
	
	private lazy var payloadView: UITextView = {
		let v = UITextView()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.isScrollEnabled = false
		v.delegate = self
		return v
	}()
	
	private lazy var shouldPersistToggle: LabeledToggle = {
		let v = LabeledToggle()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.setTitle("persist?")
		return v
	}()
	
	private var nameFieldPlaceholder = "Enter event types, separated by commas, or leave empty"
	private lazy var nameField: UITextField = {
		let v = UITextField()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.returnKeyType = .done
		v.backgroundColor = .systemBackground
		v.placeholder = nameFieldPlaceholder
		v.font = UIFont.systemFont(ofSize: 10)
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
	
	private lazy var tapGesture: UITapGestureRecognizer = {
		let v = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
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
		contentView.addSubview(shouldPersistToggle)
		
		addGestureRecognizer(tapGesture)
		backgroundColor = UIColor(red: 0.138049, green: 0.682526, blue: 0.681526, alpha: 1)
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
			payloadView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			payloadView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
			payloadView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			payloadView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
		])
		
		NSLayoutConstraint.activate([
			payloadView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			payloadView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
			payloadView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			payloadView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
		])
		
		NSLayoutConstraint.activate([
			nameField.topAnchor.constraint(equalTo: payloadView.bottomAnchor, constant: 8),
			nameField.heightAnchor.constraint(equalToConstant: 40),
			nameField.leadingAnchor.constraint(equalTo: payloadView.leadingAnchor, constant: 0),
			nameField.widthAnchor.constraint(equalTo: payloadView.widthAnchor, multiplier: 3/4),
		])
		
		NSLayoutConstraint.activate([
			doneButton.topAnchor.constraint(equalTo: nameField.topAnchor, constant: 8),
			doneButton.heightAnchor.constraint(equalToConstant: 16),
			doneButton.trailingAnchor.constraint(equalTo: payloadView.trailingAnchor, constant: -16),
		])
		
		NSLayoutConstraint.activate([
			shouldPersistToggle.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 8),
			shouldPersistToggle.leadingAnchor.constraint(equalTo: nameField.leadingAnchor, constant: 0),
			shouldPersistToggle.trailingAnchor.constraint(lessThanOrEqualTo: nameField.trailingAnchor),
			shouldPersistToggle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
		])
		super.updateConstraints()
	}
	
	// MARK: - Actions
	
	@objc func cellTapped() {
		self.nameField.becomeFirstResponder()
	}
	
	@objc func doneButtonPressed() {
		guard let contextText = payloadView.text, contextText.count > 0 else {
			showError(view: nameField)
			return
		}
		
		guard let contextJson = try? toJson(contextText) as? [String: Any] else {
			showError(view: payloadView)
			return
		}
		
		var eventTypes: [String]? = nil
		if let eventType = nameField.text {
			eventTypes = eventType.split(separator: ",").map {String($0)}
			if eventTypes?.count == 0 {
				eventTypes = nil
			}
		}
		
		valueCreated?(
			ContextValue(
				value: contextJson,
				eventTypes:eventTypes,
				shouldPersist: shouldPersistToggle.value
			)
		)
		clear()
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

extension AddContextCell: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text.starts(with: "Tap to") {
			hidePlaceholder()
		}
	}
	
	func textViewDidChange(_ textView: UITextView) {
		hack?()
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if let text = textView.text, text.count > 0 {
		} else {
			showPlaceholder()
		}
	}
	
	func showPlaceholder() {
		payloadView.text = "Tap to enter context value as JSON"
		payloadView.textColor = .placeholderText
	}
	
	func hidePlaceholder() {
		payloadView.text = ""
		payloadView.textColor = .label
	}
}

extension AddContextCell: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		endEditing(true)
		return true
	}
}
