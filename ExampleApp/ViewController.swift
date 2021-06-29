//
//  ViewController.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 22.06.2021.
//

import UIKit
import Jitsu

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		let options = JitsuOptions(
			apiKey: "js.kxp33.aefbvu0v5guetjki2ymz6",
			trackingHost: "https://t.jitsu.com/api/v1/event"
		)
		
		Jitsu.setupClient(with: options)
		
		Jitsu.shared.trackEvent(name: "first tracer bullet event", payload: ["first event payload": "boo"])
//
//		Jitsu.shared.context.addValues(["custom key": "cool"], for: nil, persist: false)
//		Jitsu.shared.userProperties.identify(
//			userIdentifier: "leonid", email: "leosilver@yandex.ru",
//			["codename": "dinoel"],
//			sendIdentificationEvent: true
//		)
//
		Jitsu.shared.trackEvent(name: "second tracer bullet event")
//
		Jitsu.shared.trackEvent(name: "third tracer bullet event")
		Jitsu.shared.trackEvent(name: "forth tracer bullet event")


	}


}

