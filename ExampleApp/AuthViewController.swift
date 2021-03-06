//
//  AuthViewController.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 12.07.2021.
//

import Foundation
import UIKit
import Jitsu

class AuthViewController: UIViewController, UITextFieldDelegate {
		
	private var nameFieldPlaceholder = "Enter api key"
	
	private lazy var apiKeyField: UITextField = {
		let v = UITextField()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.returnKeyType = .done
		v.backgroundColor = .systemBackground
		v.placeholder = nameFieldPlaceholder
		v.font = UIFont.systemFont(ofSize: 12)
		v.textAlignment = .center
		v.delegate = self
		return v
	}()
	
	private lazy var infoLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "You can always shake your device to log out and enter another key"
		label.font = UIFont.systemFont(ofSize: 10)
		label.textAlignment = .center
		return label
	}()

	override func viewDidLoad() {
		view.addSubview(infoLabel)
		view.addSubview(apiKeyField)
		
		NSLayoutConstraint.activate([
			apiKeyField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			apiKeyField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -8),
			apiKeyField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
		])
		
		NSLayoutConstraint.activate([
			infoLabel.topAnchor.constraint(equalTo: apiKeyField.bottomAnchor, constant: 20),
			infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -8),
			infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
		])
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if signInJitsu() {
			next()
			return
		}
		
		if apiKeyField.canBecomeFirstResponder {
			apiKeyField.becomeFirstResponder()
		}
		
		let pasteboard = UIPasteboard.general
		if let copiedValue = pasteboard.string {
			apiKeyField.text = copiedValue
		}
		apiKeyField.selectAll(self)
	}
	
	func next() {
		apiKeyField.endEditing(true)
		showShowcase()
	}
	
	private func showShowcase() {
		let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
		let showcaseVC = storyboard.instantiateViewController(withIdentifier: "showcase")
		showcaseVC.modalPresentationStyle = .fullScreen
		show(showcaseVC, sender: self)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if let apiKey = textField.text, apiKey.count > 0 {
			saveApiKey(apiKey)
			signInJitsu()
			next()
			return true
		}
		return false
	}

	
}

