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


class NetworkService {
	
	private var apiKey: String
	private var host: String
	
	init(apiKey: String, host: String) {
		self.apiKey = apiKey
		self.host = host
	}
	
	typealias SendBatchCompletion = (Result<EventsBatch.BatchId, NetworkServiceError>) -> Void
	
	func sendBatch(_ batch: EventsBatch, completion: @escaping SendBatchCompletion) {
		let url = URL(string: host)!
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
 		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue(apiKey, forHTTPHeaderField: "x-auth-token")
		
		let body = jsonFromBatch(batch, apiKey: apiKey)
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
			
	private func jsonFromBatch(_ batch: EventsBatch, apiKey: String) -> [String: Any] {
		
		var template = batch.template
		template["api_key"] = apiKey
		
		return [
			"template": template,
			"events": {
				batch.events.map {jsonFromEvent($0)}
			}()
		]
	}
	
	private func jsonFromEvent(_ event: EnrichedEvent) -> [String: Any] {
		var dict: [String: Any] = [
			"event_id": event.eventId,
			"event_type": event.name
		]
		
		dict.merge(event.payload) { (val1, val2) in return val1 }
		dict.merge(event.userProperties) { (val1, val2) in return val1 }
		dict.merge(event.context) { (val1, val2) in return val1 }
		
		return dict
	}
}