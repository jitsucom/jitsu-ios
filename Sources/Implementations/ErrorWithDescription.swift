//
//  ErrorWithDescription.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 14.07.2021.
//

import Foundation

protocol ErrorWithDescription: Error {
	var errorDescription: String { get }
}

