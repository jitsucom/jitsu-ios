//
//  ViewController.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 22.06.2021.
//

import UIKit
import Jitsu

class ViewController: UIViewController {
	
//	var sdk: JitsuClient = {
//		let options = JitsuOptions(
//			apiKey: "s2s.kxp33.5shyyg0f7ryliseocab2oo",
//			trackingHost: "t.jitsu.com/api/v1/event"
//		)
//	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		let options = JitsuOptions(
			apiKey: "js.kxp33.aefbvu0v5guetjki2ymz6",
			trackingHost: "t.jitsu.com/api/v1/event"
		)
		
		Jitsu.setupClient(with: options)
		let client = Jitsu.shared
		
		client.trackEvent(name: "tracer bullet event")
	}


}

