//
//  ViewController.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 22.06.2021.
//

import UIKit
import Jitsu

class ViewController: UIViewController {
	
	private lazy var button: UIButton = {
		let v = UIButton(type: .system)
		v.addTarget(self, action: #selector(sendEvent), for: .touchUpInside)
		v.translatesAutoresizingMaskIntoConstraints = false
		v.setTitle("send", for: .normal)
		return v
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(button)
		NSLayoutConstraint.activate([
			button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
			button.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0),
		])
		
		let options = JitsuOptions(
			apiKey: "js.kxp33.aefbvu0v5guetjki2ymz6",
			trackingHost: "https://t.jitsu.com/api/v1/event"
		)
		
		Jitsu.setupClient(with: options)
		
		print("\n====\n")
//		Jitsu.shared.context.addValues(["custom key": "cool"], for: nil, persist: true)
		print("\n====\n")
//		Jitsu.shared.context.addValues(["custom key": "awesome"], for: ["first event"], persist: true)
		
		

//		Jitsu.shared.context.removeValue(for: "custom key", for: nil)
				
		Jitsu.shared.trackEvent(name: "first tracer bullet event", payload: ["first event payload": "boo"])
//		Jitsu.shared.sendingBatchesPeriod = 1
//		Jitsu.shared.trackEvent(name: "first event")
		
		// output:
		// removed ["custom key": "cool"]
		// but not removed ["custom key": "awesome"]
		

//
//		Jitsu.shared.context.addValues(["custom key": "cool"], for: nil, persist: false)
//		Jitsu.shared.userProperties.identify(
//			userIdentifier: "leonid", email: "leosilver@yandex.ru",
//			["codename": "dinoel"],
//			sendIdentificationEvent: true
//		)
//
//		Jitsu.shared.trackEvent(name: "second tracer bullet event")
////
//		Jitsu.shared.trackEvent(name: "third tracer bullet event")
//		Jitsu.shared.trackEvent(name: "forth tracer bullet event")


	}
	
	@objc private func sendEvent() {
		Jitsu.shared.trackEvent(name: "button event", payload: ["button payload": "b"])
	}


}

