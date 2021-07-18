//
//  MethodToTest.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 18.07.2021.
//

import Foundation
import Jitsu

func methodToTest() {
	Jitsu.shared.trackEvent(name: "test")
}
