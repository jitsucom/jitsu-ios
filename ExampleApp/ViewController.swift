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
		let client = Jitsu.shared
		
		client.trackEvent(name: "tracer bullet event")
	}


}

