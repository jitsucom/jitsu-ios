//
//  NetworkService.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation


// todo: move
protocol ErrorWithDescription: Error {
	var errorDescription: String? { get }
}

enum NetworkServiceError: ErrorWithDescription {
	case networkError(description: String)
	case codeNot200(code: Int)
	
	var errorDescription: String? {
		switch self {
		case .networkError(let description):
			return "Network Error: \(description)"
		case .codeNot200(let code):
			return "Network Error. Code \(code)"
		}
	}
}


protocol NetworkService {
	init(apiKey: String, host: String)
	
	typealias SendBatchCompletion = (Result<Batch.BatchId, NetworkServiceError>) -> Void
	func sendBatch(_ batch: Batch, completion: @escaping SendBatchCompletion)
}


class NetworkServiceImpl: NetworkService {
	
	private var apiKey: String
	private var host: String
	
	required init(apiKey: String, host: String) {
		self.apiKey = apiKey
		self.host = host
	}
	
	func sendBatch(_ batch: Batch, completion: @escaping SendBatchCompletion) {
		let url = URL(string: host)!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
 		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue(apiKey, forHTTPHeaderField: "x-auth-token")
		
		let body = jsonFromBatch(batch, apiKey: apiKey)
		print("sending: \(body)")
		
		request.httpBody = try? JSONSerialization.data(
			withJSONObject: body,
			options: .prettyPrinted
		)
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let response = response as? HTTPURLResponse else {
				completion(.failure(.networkError(description: "\(String(describing: error))")))
				return
			}
			if response.statusCode == 200 {
				completion(.success(batch.batchId))
			} else if let error = error {
				completion(.failure(.networkError(description: error.localizedDescription)))
			} else {
				completion(.failure(.codeNot200(code: response.statusCode)))
			}
		}
		task.resume()
	}
			
	private func jsonFromBatch(_ batch: Batch, apiKey: String) -> [String: Any] {
		
		var template = batch.template
		template["api_key"] = apiKey
		
		return [
			"template": template,
			"events": {
				batch.events
			}()
		]
	}
}
