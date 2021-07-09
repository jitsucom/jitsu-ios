//
//  JsonPresentation.swift
//  ExampleApp
//
//  Created by Leonid Serebryanyy on 10.07.2021.
//

import Foundation

enum JsonError: Error {
	case invalidString
	case invalidStringEncoding
}

func toString(_ json: [String: Any]) -> String? {
	if let data1 = try? JSONSerialization.data(
		withJSONObject: json,
		options: .prettyPrinted
	),
	let convertedString = String(data: data1, encoding: String.Encoding.utf8) {
		return convertedString
	}
	return nil
}

func toJson(_ text: String) throws -> Any {
	
	guard let data = text.data(using: .utf8) else {
		throw JsonError.invalidStringEncoding
	}
	
	let json = try JSONSerialization.jsonObject(with: data, options: [])
	return json
}
