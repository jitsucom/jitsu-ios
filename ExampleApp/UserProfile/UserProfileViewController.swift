//
//  UserProfileViewController.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 10.07.2021.
//

import UIKit
import Jitsu

class UserProfileViewController: UIViewController, UITextFieldDelegate {

	private lazy var anonymousUserIdLabel: UILabel = {
		let v = UILabel()
		v.numberOfLines = 0
		v.translatesAutoresizingMaskIntoConstraints = false
		v.textAlignment = .left
		return v
	}()
	
	private lazy var userIdLabel: UILabel = {
		let v = UILabel()
		v.numberOfLines = 0
		v.translatesAutoresizingMaskIntoConstraints = false
		v.textAlignment = .left

		return v
	}()
	
	private lazy var emailTextField: UITextField = {
		let v = UITextField()
		v.translatesAutoresizingMaskIntoConstraints = false
		v.delegate = self
		v.keyboardType = .emailAddress
		v.returnKeyType = .done
		return v
	}()
	
	private lazy var changeEmailButton: UIButton = {
		let v = UIButton(type: .system)
		v.setTitle("add email", for: .normal)
		v.translatesAutoresizingMaskIntoConstraints = false
		v.addTarget(self, action: #selector(changeEmail), for: .touchUpInside)
		return v
	}()
	
	private lazy var authStateButton: UIButton = {
		let v = UIButton(type: .system)
		v.translatesAutoresizingMaskIntoConstraints = false
		v.addTarget(self, action: #selector(changeAuth), for: .touchUpInside)
		return v
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.addSubview(anonymousUserIdLabel)
		view.addSubview(userIdLabel)
		view.addSubview(emailTextField)
//		view.addSubview(changeEmailButton)
		view.addSubview(authStateButton)
		
		let offset = CGFloat(16)
		
		NSLayoutConstraint.activate([
			anonymousUserIdLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
			anonymousUserIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset),
			anonymousUserIdLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -offset),
		])
		
		NSLayoutConstraint.activate([
			userIdLabel.topAnchor.constraint(equalTo: anonymousUserIdLabel.bottomAnchor, constant: 40),
			userIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset),
			userIdLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -offset),
		])
		
		NSLayoutConstraint.activate([
			emailTextField.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: 40),
			emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: offset),
		])
		
//		NSLayoutConstraint.activate([
//			changeEmailButton.centerYAnchor.constraint(equalTo: emailTextField.centerYAnchor, constant: 0),
//			changeEmailButton.leadingAnchor.constraint(equalTo: emailTextField.trailingAnchor, constant: offset),
//			changeEmailButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -offset),
//			changeEmailButton.widthAnchor.constraint(equalToConstant: 80),
//		])
		
		NSLayoutConstraint.activate([
			authStateButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40),
			authStateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
		])
    }
	
	override func viewWillAppear(_ animated: Bool) {
		reloadData()
	}
	
	func reloadData() {
		anonymousUserIdLabel.text = "anonymous_id: \n\(Jitsu.shared.userProperties.anonymousUserId)"
		userIdLabel.text = "user id: \n\(Jitsu.shared.userProperties.userIdentifier ?? "none")"
		
		if let email = Jitsu.shared.userProperties.email, email.count > 0 {
			emailTextField.text = email
		} else {
			emailTextField.text = nil
			emailTextField.placeholder = "enter email"
		}
		
		if Jitsu.shared.userProperties.userIdentifier != nil {
			authStateButton.setTitle("sign out", for: .normal)
		} else {
			authStateButton.setTitle("sign in", for: .normal)
		}
	}
	
	@objc func changeEmail() {
		Jitsu.shared.userProperties.updateEmail(emailTextField.text, sendIdentificationEvent: true)
		emailTextField.endEditing(true)
	}
	
	@objc func changeAuth() {
		emailTextField.endEditing(true)
		let identified = Jitsu.shared.userProperties.userIdentifier != nil
		if identified {
			Jitsu.shared.userProperties.resetUserProperties()
			authStateButton.setTitle("sign in", for: .normal)
		} else {
			Jitsu.shared.userProperties.identify(
				userIdentifier: "my_id_at_\(Date().timeString)",
				email: emailTextField.text,
				otherIds: [ : ],
				sendIdentificationEvent: true
			)
			authStateButton.setTitle("sign out", for: .normal)
		}
		reloadData()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.endEditing(true)
		changeEmail()
		return true
	}
}

