//
//  NetworkService.swift
//  Jitsu
//
//  Created by Leonid Serebryanyy on 17.06.2021.
//

import Foundation

enum NetworkServiceError: ErrorWithDescription {
	case networkError(description: String)
	case codeNot200(code: Int)
	case noResponse
	
	var errorDescription: String {
		switch self {
		case .networkError(let description):
			return "Network Error: \(description)"
		case .codeNot200(let code):
			return "Network Error. Code \(code)"
		case .noResponse:
			return "Network Error. No Internet connection"
		}
	}
}


protocol NetworkService {
	init(apiKey: String, host: String)
	
	typealias SendBatchCompletion = (Result<Batch.BatchId, NetworkServiceError>) -> Void
	func sendBatch(_ batch: Batch, completion: @escaping SendBatchCompletion)
}

func runRetryingRequest(
	request: URLRequest,
	onSuccess: @escaping (Data?)->(),
	onFailure: @escaping (NetworkServiceError)->(),
	retryCount: Int,
	attempt: Int = 0
) {
	func retryIfAppropriate(retryCount: Int, attempt: Int, error: NetworkServiceError) -> Void {
		guard retryCount > attempt else {
			onFailure(error)
			return
		}
		
		let attempt = attempt + 1
		
		logInfo("retrying, attempt \(attempt)")
		DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(30 * attempt)) {
			runRetryingRequest(request: request, onSuccess: onSuccess, onFailure: onFailure, retryCount: retryCount, attempt: attempt)
		}
	}
	
	let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
		guard let response = response as? HTTPURLResponse else {
			retryIfAppropriate(retryCount: retryCount, attempt: attempt, error: .noResponse)
			return
		}
		if response.statusCode == 200 {
			onSuccess(data)
		} else if let error = error {
			onFailure(.networkError(description: error.localizedDescription))
		} else {
			onFailure(.codeNot200(code: response.statusCode))
		}
	}
	task.resume()
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
		logInfo(from: self, "sending: \(body)")
		
		request.httpBody = body.data(using: .utf8)
		
		runRetryingRequest(
			request: request,
			onSuccess: { _ in
				logInfo(from: self, "sent \(batch.batchId)")
				completion(.success(batch.batchId))
			},
			onFailure: { error in
				logError(from: self, "sent \(batch.batchId)")
				logError("failed to send \(batch.batchId), error: \(error.errorDescription)")
				completion(.failure(error))
			},
			retryCount: 10
		)
	}
			
	private func jsonFromBatch(_ batch: Batch, apiKey: String) -> String {
		var template = batch.template
		template["api_key"] = apiKey.jsonValue
		
		let json = try! JSON([
			"template": template,
			"events": batch.events
		])
		
		return json.toString()
	}
}
