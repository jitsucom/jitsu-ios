//
//  BundleExtentions.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation

extension Bundle {
	var fullVersion: String { // e.g. 3.2.1
		let appVersion = self.infoDictionary?["CFBundleShortVersionString"] as? String
		let appBuildVersion = self.infoDictionary?["CFBundleVersion"] as? String
		let version = (appVersion ?? "") + "." + (appBuildVersion ?? "")
		return version
	}
	
	var minorVersion: String? { // e.g. 3.2
		let appVersion = self.infoDictionary?["CFBundleShortVersionString"] as? String
		return appVersion
	}
	
	var appName: String! {
		return self.infoDictionary?["CFBundleName"] as? String
	}
	
}
